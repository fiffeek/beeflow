from datetime import timedelta
from typing import Any, Dict

from airflow import settings
from airflow.configuration import conf
from airflow.dag_processing.manager import DagFileProcessorAgent
from airflow.models import DagModel
from airflow.utils.session import provide_session
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.dags_processed import DAGsProcessed

logger = Logger()


def get_agent():
    processor_timeout_seconds: int = conf.getint('core', 'dag_file_processor_timeout')
    processor_timeout = timedelta(seconds=processor_timeout_seconds)
    processor_agent = DagFileProcessorAgent(
        dag_directory=settings.DAGS_FOLDER,
        max_runs=5,
        processor_timeout=processor_timeout,
        dag_ids=[],
        pickle_dags=False,
        async_mode=False,
    )
    return processor_agent


@provide_session
def log_parsed_dags(session=None):
    dags_parsed = (
        session.query(DagModel.dag_id, DagModel.fileloc, DagModel.last_parsed_time)
        .filter(DagModel.is_active)
        .all()
    )
    for dag in dags_parsed:
        logger.info(f"DAG {dag.dag_id} last parsed {dag.last_parsed_time}, file_loc is {dag.fileloc}")


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    logger.info("Starting a single ProcessorAgent parsing loop.")
    # Deactivating the DAGs does not work correctly now
    # https://github.com/apache/airflow/blob/bf727525e1fd777e51cc8bc17285f6093277fdef/airflow/dag_processing/manager.py#L496
    # One solution would be to run this loop twice and adjust the timeout parameters?
    # The rewrite of the subprocesses could also be made...
    # Logs also seem to be lost, multiprocessing ftw btw.
    processor_agent = get_agent()
    processor_agent.start()
    processor_agent.run_single_parsing_loop()
    processor_agent.wait_until_finished()
    processor_agent.end()
    logger.info("Finished a single ProcessorAgent parsing loop.")
    log_parsed_dags()

    return DAGsProcessed().dict()
