import os
from dataclasses import dataclass
from typing import Any, Dict, Optional

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.data_classes import event_source
from aws_lambda_powertools.utilities.data_classes.kinesis_stream_event import (
    KinesisStreamEvent,
    KinesisStreamRecord,
)
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.cdc_input import CDCInput
from beeflow.packages.events.database_passthrough_event_converter import DatabasePassthroughEventConverter

logger = Logger()
cloudwatch_events = boto3.client('events')


@dataclass
class EventbridgeInput:
    beeflow_event: BeeflowEvent
    input: KinesisStreamRecord


def prepare_input(event: Dict[str, Any]) -> CDCInput:
    copied = {}
    for key, value in event.items():
        if value == "f":
            copied[key] = False
            continue
        if value == "t":
            copied[key] = True
            continue
        if isinstance(value, str) and value.lower() in ["none", "nonetype", "none_type", "null", "nil"]:
            copied[key] = None
            continue
        copied[key] = value
    return CDCInput(metadata=copied)


def to_event_bridge_event(event: KinesisStreamRecord) -> Optional[EventbridgeInput]:
    logger.info("Converting the event to a beeflow event for event bridge")
    data = event.kinesis.data_as_json()

    if "data" not in data or "metadata" not in data:
        logger.warning("Event does not contain `data` field")
        return None

    if "metadata" in data and "operation" in data["metadata"] and data["metadata"]["operation"] == "delete":
        logger.warning("Skipping delete rows from CDC")
        return None

    # Data about a specific transaction log item
    cdc_input = prepare_input(event=data["data"])
    return EventbridgeInput(
        beeflow_event=DatabasePassthroughEventConverter(
            cdc_input, table_name_hint=data["metadata"]["table-name"]
        ).convert(),
        input=event,
    )


def handle_records(event: KinesisStreamEvent, busname: str, events_client) -> Dict[str, Any]:
    transformed = [to_event_bridge_event(record) for record in event.records]
    filtered = [record for record in transformed if record is not None]

    if len(filtered) == 0:
        logger.warning("There are no events to push after filtering")
        return {"batchItemFailures": []}

    response = events_client.put_events(
        Entries=[
            {
                'Detail': entry.beeflow_event.json(),
                'DetailType': entry.beeflow_event.event_type.name,
                'Resources': [],
                'Source': 'com.beeflow.dms_cdc_forwarder',
                'EventBusName': busname,
            }
            for entry in filtered
        ]
    )

    response_with_input = zip(response["Entries"], filtered)
    failed_events = [
        {"itemIdentifier": event.input.event_id}
        for response_entry, event in response_with_input
        if 'ErrorCode' in response_entry
    ]
    return {"batchItemFailures": failed_events}


@logger.inject_lambda_context
@event_source(data_class=KinesisStreamEvent)
def handler(event: KinesisStreamEvent, context: LambdaContext) -> Dict[str, Any]:
    event_bus_name = os.environ["EVENTBRIDGE_BUS_NAME"]
    return handle_records(event, event_bus_name, cloudwatch_events)
