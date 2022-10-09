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

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.dag_created import DAGCreatedEvent
from beeflow.packages.events.new_cron_created import NewCronScheduleCreated

logger = Logger()
eventbridge_client = boto3.client('events')


def get_dag_by_id(dag_id: str) -> DAG:
    from airflow.models import DagBag
    dagbag = DagBag(process_subdir("DAGS_FOLDER"), include_examples=False)
    return dagbag.dags[dag_id]


def from_airflow_schedule_to_aws_cron(airflow_schedule: ScheduleInterval) -> str:
    pass


def create_new_cron_schedule(event: DAGCreatedEvent) -> BeeflowEvent:
    dag = get_dag_by_id(event.dag_id)
    eventbridge_client.put_rule(
        Name=dag.dag_id,
        ScheduleExpression=from_airflow_schedule_to_aws_cron(dag.normalized_schedule_interval),
        State='ENABLED',
        Description=f'Rule to trigger execution of tasks for {dag.dag_id}',
        EventBusName='default'
    )
    # TODO: Add rule target to SQS
    return NewCronScheduleCreated(dag_id=event.dag_id, rule_id=dag.dag_id)


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    for event in events:
        try:
            parsed_event: DAGCreatedEvent = parse(event=event.detail, model=DAGCreatedEvent)
            return create_new_cron_schedule(parsed_event).dict()
        except ValidationError:
            logger.warning(f"Event {event} does not conform to DAGCreatedEvent")
    return {}
