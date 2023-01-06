import os
import pathlib
from typing import Any, Dict, Optional

from airflow import DAG, AirflowException  # type: ignore[attr-defined]
from airflow.cli.commands.task_command import _capture_task_logs, _get_ti
from airflow.jobs.local_task_job import LocalTaskJob
from airflow.providers.amazon.aws.log.s3_task_handler import S3TaskHandler
from airflow.utils.cli import process_subdir
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


def flush_logs(handlers):
    for h in reversed(handlers):
        try:
            logger.info("Acquiring lock for a handler")
            h.acquire()
            logger.info("Flushing the handler")
            h.flush()
            logger.info("Flushed the logger")

            if isinstance(h, S3TaskHandler):
                logger.info("Checking if local logs exist for S3TaskHandler")
                local_loc = os.path.join(h.local_base, h.log_relative_path)
                remote_loc = os.path.join(h.remote_base, h.log_relative_path)
                if os.path.exists(local_loc):
                    logger.info("Logs exist, pushing to s3")
                    log = pathlib.Path(local_loc).read_text()
                    h.s3_write(log, remote_loc)
                    logger.info("Pushed logs to S3")

        except (OSError, ValueError):
            pass
        finally:
            h.release()


def _run_task_by_local_task_job(pool, task_instance):
    """Run LocalTaskJob, which monitors the raw task execution process."""
    run_job = LocalTaskJob(
        task_instance=task_instance,
        pool=pool,
    )
    try:
        run_job.run()
    finally:
        logger.info("Closing task instance logger and flushing logs")
        flush_logs(task_instance.log.handlers)


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


@logger.inject_lambda_context
@event_parser(model=TaskInstanceQueued)
def handler(event: TaskInstanceQueued, context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    logger.info(f"Executing {event.task_id} from {event.dag_id}")
    execute_work(event=event)
    return {}
