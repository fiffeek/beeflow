from datetime import timedelta
from typing import Any, Dict, List

from airflow import settings
from airflow.configuration import conf
from airflow.dag_processing.manager import DagFileProcessorAgent
from airflow.models import DagModel
from airflow.utils.session import provide_session
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.dags_processed import DAGsProcessed
from beeflow.packages.events.trigger_dags_processing_command import TriggerDAGsProcessingCommand

logger = Logger()


def get_agent():
    processor_timeout_seconds: int = conf.getint('core', 'dag_file_processor_timeout')
    processor_timeout = timedelta(seconds=processor_timeout_seconds)
    processor_agent = DagFileProcessorAgent(
        dag_directory=settings.DAGS_FOLDER,
        max_runs=10,
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
@event_parser(model=TriggerDAGsProcessingCommand, envelope=envelopes.SqsEnvelope)
def handler(event: List[TriggerDAGsProcessingCommand], context: LambdaContext) -> Dict[str, Any]:
    dags_downloader = DagsDownloader()
    dags_downloader.download_dags()
    logger.info("Starting a single ProcessorAgent parsing loop.")
    processor_agent = get_agent()
    processor_agent.start()
    for _ in range(max(dags_downloader.get_dag_files_number(), len(event))):
        logger.info("Looping through single parsing loop")
        processor_agent.run_single_parsing_loop()
        processor_agent.wait_until_finished()
    processor_agent.end()
    logger.info("Finished a single ProcessorAgent parsing loop.")
    log_parsed_dags()

    return DAGsProcessed().dict()
