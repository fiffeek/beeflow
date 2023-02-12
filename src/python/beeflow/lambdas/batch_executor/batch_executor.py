import json
import os
from typing import Any, Dict, List

import backoff
import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser, parse
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.config.constants.constants import ConfigConstants
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued
from beeflow.packages.sfn.name import StepFunctionsNameCreator

logger = Logger()

sfn_client = boto3.client('stepfunctions')


def prepare_input(event: TaskInstanceQueued) -> str:
    """Serializes the event input into a json string."""
    return json.dumps(
        {os.environ[ConfigConstants.SERIALIZED_INPUT_FIELD_NAME_ENV_VAR]: json.dumps(event.dict())}
    )


@backoff.on_exception(backoff.expo, Exception, max_time=800)
def trigger_step_functions(event: TaskInstanceQueued) -> None:
    state_machine_arn = os.environ[ConfigConstants.BATCH_EXECUTOR_STATE_MACHINE_ENV_VAR]
    response = sfn_client.start_execution(
        stateMachineArn=state_machine_arn,
        name=StepFunctionsNameCreator.from_ti_queued_event(event),
        input=prepare_input(event),
    )
    logger.info(f"Scheduled the worker for batch {response}")


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    for event in events:
        parsed_event = parse(event=event.detail, model=TaskInstanceQueued)  # type: ignore[arg-type]
        logger.info(f"Triggering SFN for {parsed_event.task_id} from {parsed_event.dag_id}")
        trigger_step_functions(event=parsed_event)
    return {}
