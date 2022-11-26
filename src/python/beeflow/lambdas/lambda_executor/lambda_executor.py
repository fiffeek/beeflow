import json
import os
from typing import Any, Dict, List

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser, parse
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.config.constants.constants import ConfigConstants
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()

sfn_client = boto3.client('stepfunctions')


def get_name(event: TaskInstanceQueued) -> str:
    name = f"{event.dag_id}-{event.run_id}-{event.task_id}"
    name = ''.join(ch for ch in name if ch.isalnum() or ch == '-' or ch == '_')
    return name[0:79]


def prepare_input(event: TaskInstanceQueued) -> str:
    """Serializes the event input into a json string."""
    return json.dumps({os.environ[ConfigConstants.INPUT_LAMBDA_FIELD_NAME_ENV_VAR]: event.dict()})


def trigger_step_functions(event: TaskInstanceQueued) -> None:
    state_machine_arn = os.environ[ConfigConstants.LAMBDA_EXECUTOR_STATE_MACHINE_ENV_VAR]
    response = sfn_client.start_execution(
        stateMachineArn=state_machine_arn,
        name=get_name(event),
        input=prepare_input(event),
    )
    logger.info(f"Scheduled the worker for lambda {response}")


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    for event in events:
        parsed_event: TaskInstanceQueued = parse(event=event.detail, model=TaskInstanceQueued)
        logger.info(f"Triggering SFN for {parsed_event.task_id} from {parsed_event.dag_id}")
        trigger_step_functions(event=parsed_event)
    return {}
