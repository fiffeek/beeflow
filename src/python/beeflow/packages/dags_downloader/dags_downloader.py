import os

import boto3
from airflow import settings
from aws_lambda_powertools import Logger
from beeflow.packages.config.config import Configuration

s3 = boto3.resource('s3')
logger = Logger()


class DagsDownloader:
    def __init__(self):
        self.bucket_name = os.environ[Configuration.DAGS_BUCKET_ENV_VAR]
        self.bucket = s3.Bucket(self.bucket_name)

    def download_dags(self):
        logger.info(f"Downloading DAG files locally to {self.bucket_name}.")
        for s3_object in self.bucket.objects.all():
            path, filename = os.path.split(s3_object.key)
            local_path = os.path.join(settings.DAGS_FOLDER, path)
            if local_path.startswith("dags/"):
                local_path = local_path[len("dags/") :]
            os.makedirs(local_path, exist_ok=True)
            full_local_path = os.path.join(local_path, filename)
            logger.info(f"Downloading {s3_object.key} to {full_local_path}")
            self.bucket.download_file(s3_object.key, full_local_path)
        logger.info("DAG files downloaded locally.")
