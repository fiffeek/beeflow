import logging
from typing import Dict, Any, List, Optional

from airflow import DAG, AirflowException
from airflow.cli.commands.task_command import _get_ti, _capture_task_logs
from airflow.executors.executor_constants import LOCAL_EXECUTOR
from airflow.executors.executor_loader import ExecutorLoader
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse, envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


# TODO: Rewrite this executor to use Step functions so if any issue arises there is a watcher
# that propagates the issues to the database.

def _run_task_by_executor(pool, task_instance):
    """Sends the task to the executor for execution."""
    executor = ExecutorLoader.load_executor(executor_name=ExecutorLoader.executors[LOCAL_EXECUTOR])
    executor.job_id = "manual"
    executor.start()
    executor.queue_task_instance(
        task_instance,
        pool=pool,
    )
    executor.heartbeat()
    executor.end()


def get_dag(subdir: Optional[str], dag_id: str) -> "DAG":
    """Returns DAG of a given dag_id"""
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
        _run_task_by_executor(pool=event.pool, task_instance=ti)


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    for event in events:
        parsed_event: TaskInstanceQueued = parse(event=event.detail, model=TaskInstanceQueued)
        logger.info(f"Executing {parsed_event.task_id} from {parsed_event.dag_id}")
        execute_work(event=parsed_event)
    return {}
