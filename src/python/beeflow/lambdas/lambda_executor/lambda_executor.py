from typing import Dict, Any, List

from airflow import DAG
from airflow.cli.commands.task_command import _get_ti, _capture_task_logs, _run_task_by_local_task_job
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse, envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued
from airflow.utils.cli import (
    get_dag,
)

logger = Logger()


def execute_work(event: TaskInstanceQueued):
    # Assumes the task code lives under DAGS_FOLDER
    dag: DAG = get_dag("DAGS_FOLDER", event.dag_id)
    task = dag.get_task(task_id=event.task_id)
    ti, _ = _get_ti(task, exec_date_or_run_id=event.run_id, map_index=event.map_index, pool=event.pool)
    ti.init_run_context()
    with _capture_task_logs(ti):
        _run_task_by_local_task_job({}, ti)


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    for event in events:
        parsed_event: TaskInstanceQueued = parse(event=event.detail, model=TaskInstanceQueued)
        logger.info(f"Executing {parsed_event.task_id} from {parsed_event.dag_id}")
        execute_work(event=parsed_event)
    return {}
