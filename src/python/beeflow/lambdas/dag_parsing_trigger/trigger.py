from typing import Any, Dict, List

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import S3Model, S3RecordModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.events.dags_processing_triggered import DAGsProcessingTriggered
from beeflow.packages.utils.list import flatten

logger = Logger()


# @logger.inject_lambda_context
# @event_parser(model=S3Model, envelope=envelopes.SqsEnvelope)
# def handler(events: List[S3Model], context: LambdaContext) -> Dict[str, Any]:
@logger.inject_lambda_context
def handler(events, context: LambdaContext) -> Dict[str, Any]:
    logger.info(f"Handler for DAG parsing invoked. Some DAGs might have changed. {events}")
    # all_records: List[S3RecordModel] = flatten([event.Records for event in events])
    # affected_files_log = "\n".join(
    #     [
    #         f"name={record.s3.object.key}, size={record.s3.object.size}, eTag={record.s3.object.eTag}"
    #         for record in all_records
    #     ]
    # )
    # logger.info(f"Affected files:\n {affected_files_log}")

    return DAGsProcessingTriggered().dict()
