import json
import os
from typing import Any, Dict, List, Optional

import boto3
from airflow import DAG
from airflow.models.dag import ScheduleInterval
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser, parse
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.config.constants.constants import ConfigConstants
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.dag_created import DAGCreatedEvent
from beeflow.packages.events.dag_cron_triggered import DAGCronTriggered
from beeflow.packages.events.dag_schedule_updater_empty_event import DAGScheduleUpdaterEmptyEvent
from beeflow.packages.events.dag_updated import DAGUpdatedEvent
from beeflow.packages.events.new_cron_created import NewCronScheduleCreated
from pydantic import ValidationError

logger = Logger()
eventbridge_client = boto3.client('events')
# Cron rules can only run on the default bus
EVENTBUS_NAME = 'default'


def get_dag_by_id(dag_id: str) -> DAG:
    from airflow.models import DagBag

    dagbag = DagBag(process_subdir("DAGS_FOLDER"), include_examples=False)
    return dagbag.dags[dag_id]


# Example of an Airflow cron: "0 0 * * *"
# Example of the desired cron: "cron(0 20 * * ? *)"
def from_airflow_schedule_to_aws_cron(airflow_schedule: ScheduleInterval) -> str:
    if not isinstance(airflow_schedule, str):
        raise ValueError(
            f"Currently supporting only schedule intervals for cron string type,"
            f" got {airflow_schedule} instead"
        )
    airflow_cron = airflow_schedule.replace('"', '')
    parts = airflow_cron.split(' ')
    if len(parts) < 5:
        raise ValueError(f"Invalid Airflow cron format, got {airflow_schedule}, expected sample: '0 0 * * *'")

    minutes = parts[0]
    hours = parts[1]
    day_month = parts[2]
    month = parts[3]
    day_week = parts[4].replace("*", "?")
    year = "*"

    return f"cron({minutes} {hours} {day_month} {month} {day_week} {year})"


def get_rule_state(is_dag_paused: bool) -> str:
    if is_dag_paused:
        return 'DISABLED'
    return 'ENABLED'


def upsert_new_cron_schedule(dag_id: str) -> BeeflowEvent:
    """Pulls the DAG dag_id from the metadata database with the most recent
    information.

    Upserts the cron schedule and enables or disables the cron rule if
    the DAG is paused or un-paused accordingly.
    """

    dag = get_dag_by_id(dag_id)
    rule_name = dag.dag_id
    target = os.environ[ConfigConstants.DAG_SCHEDULE_RULES_TARGET_ARN_ENV_VAR]

    logger.info(f"Putting a new event bridge rule for cron triggering {dag_id}")
    eventbridge_client.put_rule(
        Name=rule_name,
        ScheduleExpression=from_airflow_schedule_to_aws_cron(dag.normalized_schedule_interval),
        State=get_rule_state(is_dag_paused=dag.get_is_paused()),
        Description=f'Rule to trigger execution of tasks for {dag_id}',
        EventBusName=EVENTBUS_NAME,
    )
    logger.info(f"Attaching a new target {target} for rule {rule_name}")
    eventbridge_client.put_targets(
        Rule=rule_name,
        EventBusName=EVENTBUS_NAME,
        Targets=[
            {
                'Id': 'trigger-scheduler-by-sqs-forward',
                'Arn': target,
                'InputTransformer': {
                    'InputPathsMap': {"eventTime": "$.time"},
                    'InputTemplate': json.dumps(
                        DAGCronTriggered(dag_id=dag.dag_id, trigger_time="<eventTime>").dict()
                    ),
                },
                'SqsParameters': {
                    'MessageGroupId': os.environ[
                        ConfigConstants.DAG_SCHEDULE_RULES_TARGET_MESSAGE_GROUP_ID_ENV_VAR
                    ]
                },
            }
        ],
    )

    return NewCronScheduleCreated(dag_id=dag_id, rule_id=dag.dag_id)


def act_on_dag_created_event(event: EventBridgeModel) -> Optional[BeeflowEvent]:
    try:
        parsed_event: DAGCreatedEvent = parse(event=event.detail, model=DAGCreatedEvent)
        return upsert_new_cron_schedule(parsed_event.dag_id)
    except ValidationError:
        logger.warning(f"Event {event} does not conform to DAGCreatedEvent")
    return None


def act_on_dag_updated_event(event: EventBridgeModel) -> Optional[BeeflowEvent]:
    try:
        parsed_event: DAGUpdatedEvent = parse(event=event.detail, model=DAGUpdatedEvent)
        return upsert_new_cron_schedule(parsed_event.dag_id)
    except ValidationError:
        logger.warning(f"Event {event} does not conform to DAGCreatedEvent")
    return None


def act_on_event(event: EventBridgeModel) -> BeeflowEvent:
    handlers = [act_on_dag_created_event, act_on_dag_updated_event]
    for event_handler in handlers:
        maybe_result = event_handler(event)
        if maybe_result is not None:
            return maybe_result
    return DAGScheduleUpdaterEmptyEvent()


# TODO: On DAG deletion, delete the cron rule
@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> List[Dict[str, Any]]:
    DagsDownloader().download_dags()
    return [act_on_event(event).dict() for event in events]
