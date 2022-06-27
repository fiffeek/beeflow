from datetime import timedelta

from airflow import settings
from airflow.configuration import conf
from airflow.dag_processing.manager import DagFileProcessorAgent


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
