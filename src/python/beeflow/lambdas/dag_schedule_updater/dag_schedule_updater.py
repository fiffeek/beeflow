import json
import os
from typing import Dict, Any, List

import boto3
from airflow import DAG
from airflow.models.dag import ScheduleInterval
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse, envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from pydantic import ValidationError

from beeflow.packages.config.config import Configuration
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.dag_created import DAGCreatedEvent
from beeflow.packages.events.dag_cron_triggered import DAGCronTriggered
from beeflow.packages.events.new_cron_created import NewCronScheduleCreated

logger = Logger()
eventbridge_client = boto3.client('events')


def get_dag_by_id(dag_id: str) -> DAG:
    from airflow.models import DagBag
    dagbag = DagBag(process_subdir("DAGS_FOLDER"), include_examples=False)
    return dagbag.dags[dag_id]


# Example of an Airflow cron: "0 0 * * *"
# Example of the desired cron: "cron(0 20 * * ? *)"
def from_airflow_schedule_to_aws_cron(airflow_schedule: ScheduleInterval) -> str:
    if not isinstance(airflow_schedule, str):
        raise ValueError(
            f"Currently supporting only schedule intervals for cron string type, got {airflow_schedule} instead")
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


def create_new_cron_schedule(event: DAGCreatedEvent) -> BeeflowEvent:
    dag = get_dag_by_id(event.dag_id)
    rule_name = dag.dag_id
    eventbus_name = 'default'  # Cron rules can only run on the default bus
    target = os.environ[Configuration.DAG_SCHEDULE_RULES_TARGET_ARN_ENV_VAR]

    logger.info(f"Putting a new event bridge rule for cron triggering {event.dag_id}")
    eventbridge_client.put_rule(
        Name=rule_name,
        ScheduleExpression=from_airflow_schedule_to_aws_cron(dag.normalized_schedule_interval),
        State='ENABLED',
        Description=f'Rule to trigger execution of tasks for {dag.dag_id}',
        EventBusName=eventbus_name
    )
    logger.info(f"Attaching a new target {target} for rule {rule_name}")
    eventbridge_client.put_targets(
        Rule=rule_name,
        EventBusName=eventbus_name,
        Targets=[
            {
                'Id': 'trigger-scheduler-by-sqs-forward',
                'Arn': target,
                'Input': json.dumps(DAGCronTriggered(dag_id=dag.dag_id).dict())
            }
        ])

    return NewCronScheduleCreated(dag_id=event.dag_id, rule_id=dag.dag_id)


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    for event in events:
        # TODO: On DAG update, check if rule needs to be changed
        #  (that should include disabling / enabling the rule on DAG pause)
        # TODO: On DAG deletion, delete the cron rule
        try:
            parsed_event: DAGCreatedEvent = parse(event=event.detail, model=DAGCreatedEvent)
            return create_new_cron_schedule(parsed_event).dict()
        except ValidationError:
            logger.warning(f"Event {event} does not conform to DAGCreatedEvent")
    return {}
