import os
from typing import Any, Dict

import backoff
import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType
from beeflow.packages.events.cdc_input import CDCInput
from beeflow.packages.events.dag_created import DAGCreatedEvent
from beeflow.packages.events.database_passthrough_event_converter import DatabasePassthroughEventConverter

logger = Logger()
cloudwatch_events = boto3.client('events')


def to_event_bridge_event(event: CDCInput) -> BeeflowEvent:
    logger.info("Converting the event to a beeflow event for event bridge")

    metadata = event.metadata
    if "event_type" in metadata:
        event_type = metadata["event_type"]

        if event_type == BeeflowEventType.DAG_CREATED:
            return DAGCreatedEvent(dag_id=metadata["dag_id"])
    else:
        return DatabasePassthroughEventConverter(event).convert()

    raise ValueError(f"Event type not supported {event_type}")


@backoff.on_exception(backoff.expo, Exception, max_time=800)
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
    if response["FailedEntryCount"] > 0:
        raise Exception("Failed to publish to the eventbridge")
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
