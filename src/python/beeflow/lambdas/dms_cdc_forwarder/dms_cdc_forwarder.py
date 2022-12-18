import os
from typing import Any, Dict, Optional

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.batch import BatchProcessor, EventType, batch_processor
from aws_lambda_powertools.utilities.data_classes.kinesis_stream_event import KinesisStreamRecord
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.cdc_input import CDCInput
from beeflow.packages.events.database_passthrough_event_converter import DatabasePassthroughEventConverter

logger = Logger()
processor = BatchProcessor(event_type=EventType.KinesisDataStreams)
cloudwatch_events = boto3.client('events')


def prepare_input(event: Dict[str, Any]) -> CDCInput:
    copied = {}
    for key, value in event.items():
        if value == "f":
            copied[key] = False
            continue
        if value == "t":
            copied[key] = True
            continue
        if value.lower() in ["none", "nonetype", "none_type", "null", "nil"]:
            copied[key] = None
            continue
        copied[key] = value
    return CDCInput(metadata=copied)


def to_event_bridge_event(event: KinesisStreamRecord) -> Optional[BeeflowEvent]:
    logger.info("Converting the event to a beeflow event for event bridge")
    data = event.kinesis.data_as_json()

    if "data" not in data:
        logger.warning("Event does not contain `data` field")
        return None

    # Data about a specific transaction log item
    cdc_input = prepare_input(event=data["data"])
    return DatabasePassthroughEventConverter(cdc_input).convert()


def record_handler(event: KinesisStreamRecord):
    event_bridge_event = to_event_bridge_event(event)
    if event_bridge_event is None:
        return

    response = cloudwatch_events.put_events(
        Entries=[
            {
                'Detail': event_bridge_event.json(),
                'DetailType': event_bridge_event.event_type.name,
                'Resources': [],
                'Source': 'com.beeflow.dms_cdc_forwarder',
                'EventBusName': os.environ["EVENTBRIDGE_BUS_NAME"],
            }
        ]
    )
    if response["FailedEntryCount"] > 0:
        raise Exception("Failed to publish to the eventbridge")
    logger.info(f"Put events returned {response}")
    return response


@logger.inject_lambda_context
@batch_processor(record_handler=record_handler, processor=processor)
def handler(event, context: LambdaContext) -> Dict[str, Any]:
    return processor.response()
