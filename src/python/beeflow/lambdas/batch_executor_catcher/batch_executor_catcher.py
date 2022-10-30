import json
import os
from typing import Dict, Any, Optional

from airflow import DAG
from airflow.cli.commands.task_command import _get_ti
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.config.config import Configuration
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


def get_dag(subdir: Optional[str], dag_id: str) -> Optional["DAG"]:
    """Returns DAG of a given dag_id"""
    from airflow.models import DagBag
    dagbag = DagBag(process_subdir(subdir), include_examples=False)
    if dag_id not in dagbag.dags:
        return None
    return dagbag.dags[dag_id]


def mark_task_as_failed(event: TaskInstanceQueued):
    # Assumes the task code lives under DAGS_FOLDER
    dag: Optional[DAG] = get_dag("DAGS_FOLDER", event.dag_id)
    if dag is None:
        return

    task = dag.get_task(task_id=event.task_id)
    ti, _ = _get_ti(task, exec_date_or_run_id=event.run_id, map_index=event.map_index, pool=event.pool)
    ti.init_run_context()

    logger.info(f"Marking {event.task_id} from {event.dag_id} as failed")
    ti.error()


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    serialized_event = event[os.environ[Configuration.SERIALIZED_INPUT_FIELD_NAME_ENV_VAR]]
    parsed_event: TaskInstanceQueued = parse(event=json.loads(serialized_event), model=TaskInstanceQueued)
    mark_task_as_failed(event=parsed_event)
    return {}
