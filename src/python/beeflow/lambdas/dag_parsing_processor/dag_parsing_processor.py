import os
from datetime import timedelta
from typing import Any, Dict

import boto3
from airflow import settings
from airflow.configuration import conf
from airflow.dag_processing.manager import DagFileProcessorAgent
from airflow.models import DagModel
from airflow.utils.session import provide_session
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.config.config import Configuration
from beeflow.packages.events.dags_processed import DAGsProcessed

logger = Logger()

s3 = boto3.resource('s3')


def download_dags(bucket):
    for s3_object in bucket.objects.all():
        path, filename = os.path.split(s3_object.key)
        local_path = os.path.join(settings.DAGS_FOLDER, path)
        if local_path.startswith("dags/"):
            local_path = local_path[len("dags/") :]
        os.makedirs(local_path, exist_ok=True)
        full_local_path = os.path.join(local_path, filename)
        logger.info(f"Downloading {s3_object.key} to {full_local_path}")
        bucket.download_file(s3_object.key, full_local_path)


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
    bucket_name = os.environ[Configuration.DAGS_BUCKET_ENV_VAR]
    logger.info(f"Downloading DAG files locally to {bucket_name}.")
    bucket = s3.Bucket(bucket_name)
    download_dags(bucket)
    logger.info("DAG files downloaded locally.")

    logger.info("Starting a single ProcessorAgent parsing loop.")
    processor_agent = get_agent()
    processor_agent.start()
    processor_agent.run_single_parsing_loop()
    processor_agent.wait_until_finished()
    processor_agent.end()
    logger.info("Finished a single ProcessorAgent parsing loop.")
    log_parsed_dags()

    return DAGsProcessed().dict()
