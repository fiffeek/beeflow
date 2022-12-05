import argparse
import logging
from typing import Any, Dict, Optional

from airflow import DAG, AirflowException  # type: ignore[attr-defined]
from airflow.cli.commands.task_command import _capture_task_logs, _get_ti
from airflow.jobs.local_task_job import LocalTaskJob
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


def _run_task_by_local_task_job(pool, task_instance):
    """Run LocalTaskJob, which monitors the raw task execution process."""
    run_job = LocalTaskJob(
        task_instance=task_instance,
        pool=pool,
    )
    try:
        run_job.run()
    finally:
        logging.shutdown()


def get_dag(subdir: Optional[str], dag_id: str) -> "DAG":
    """Returns DAG of a given dag_id."""
    from airflow.models import DagBag

    dagbag = DagBag(process_subdir(subdir), include_examples=False)
    if dag_id not in dagbag.dags:
        raise AirflowException(
            f"Dag {dag_id!r} could not be found; either it does not exist or it failed to parse."
        )
    return dagbag.dags[dag_id]


def execute_work(event: TaskInstanceQueued):
    # Assumes the task code lives under DAGS_FOLDER
    dag: DAG = get_dag("DAGS_FOLDER", event.dag_id)
    task = dag.get_task(task_id=event.task_id)
    ti, _ = _get_ti(task, exec_date_or_run_id=event.run_id, map_index=event.map_index, pool=event.pool)
    ti.init_run_context()
    with _capture_task_logs(ti):
        _run_task_by_local_task_job(pool=event.pool, task_instance=ti)


def handler(event: TaskInstanceQueued) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    execute_work(event=event)
    return {}


parser = argparse.ArgumentParser(description='Process Airflow event.')
parser.add_argument('--event', type=str, required=True, help='a TaskInstanceQueued event serialized')
args = parser.parse_args()

parsed_event: TaskInstanceQueued = parse(event=args.event, model=TaskInstanceQueued)
logger.info(f"Executing {parsed_event.task_id} from {parsed_event.dag_id}")

handler(event=parsed_event)
