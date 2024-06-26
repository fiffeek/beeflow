import json
import os
import time
from typing import Any, Dict, List

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import S3Model, S3RecordModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.config.constants.constants import ConfigConstants
from beeflow.packages.events.dags_processing_triggered import DAGsProcessingTriggered
from beeflow.packages.events.trigger_dags_processing_command import TriggerDAGsProcessingCommand
from beeflow.packages.utils.list import flatten

logger = Logger()


def prepare_event() -> TriggerDAGsProcessingCommand:
    # SQS will deduplicate messages on the content hash
    # In this case we want to trigger reprocessing if the DAG changed in <5mins
    current_time = time.time()
    time_to_min_intervals = int(current_time / 60)
    return TriggerDAGsProcessingCommand(triggered_at=str(time_to_min_intervals))


def trigger_processing():
    sqs = boto3.client('sqs')
    processor_queue_url = os.environ[ConfigConstants.DAG_PARSING_PROCESSOR_QUEUE_URL_ENV_VAR]
    response = sqs.send_message(
        QueueUrl=processor_queue_url,
        MessageBody=json.dumps(prepare_event().dict()),
        MessageGroupId='globalDedup',
    )
    logger.info(f"Successfully triggered processing of all DAGs {response}")


@logger.inject_lambda_context
@event_parser(model=S3Model, envelope=envelopes.SqsEnvelope)
def handler(events: List[S3Model], context: LambdaContext) -> Dict[str, Any]:
    logger.info("Handler for DAG parsing invoked. Some DAGs might have changed.")
    all_records: List[S3RecordModel] = flatten([event.Records for event in events])
    affected_files_log = "\n".join(
        [
            f"name={record.s3.object.key}, size={record.s3.object.size}, eTag={record.s3.object.eTag}"
            for record in all_records
        ]
    )
    logger.info(f"Affected files:\n {affected_files_log}")

    # For now triggering a global processing for all the DAGs.
    # TODO: Can be broken down to parallel processing over the changed DAGs from affected_files_log
    trigger_processing()

    return DAGsProcessingTriggered().dict()
