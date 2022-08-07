import os
from typing import Dict, Any

import boto3
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType
from beeflow.packages.events.cdc_input import CDCInput
from aws_lambda_powertools import Logger

from beeflow.packages.events.dag_created import DAGCreatedEvent

logger = Logger()
cloudwatch_events = boto3.client('events')


def to_event_bridge_event(event: CDCInput) -> BeeflowEvent:
    logger.info("Converting the event to a beeflow event for event bridge")

    metadata = event.metadata
    event_type = metadata["event_type"]

    if event_type == BeeflowEventType.DAG_CREATED:
        return DAGCreatedEvent(dag_id=metadata["dag_id"])

    raise ValueError(f"Event type not supported {event_type}")


def push_to_event_bridge(event: CDCInput):
    event_bridge_event = to_event_bridge_event(event)
    response = cloudwatch_events.put_events(
        Entries=[
            {
                'Detail': event_bridge_event.json(),
                'DetailType': event_bridge_event.event_type.name,
                'Resources': [],
                'Source': 'com.beeflow.change_data_capture_forwarder',
                'EventBusName': os.environ["EVENTBRIDGE_BUS_NAME"],
            }
        ]
    )
    logger.info(f"Put events returned {response}")
    return response


@event_parser(model=CDCInput)
@logger.inject_lambda_context
def handler(event: CDCInput, context: LambdaContext) -> Dict[str, Any]:
    response = push_to_event_bridge(event)

    return {
        "lambda_request_id": context.aws_request_id,
        "lambda_arn": context.invoked_function_arn,
        "success": response["FailedEntryCount"] == 0,
    }
