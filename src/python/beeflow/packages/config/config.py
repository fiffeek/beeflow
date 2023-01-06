import os

import boto3
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities import parameters
from beeflow.packages.config.constants.constants import ConfigConstants

logger = Logger()


class Configuration:
    @staticmethod
    def load(
        app_config_name=None,
        environment=None,
        application=None,
        airflow_home=None,
        config_bucket=None,
        config_bucket_key=None,
    ):
        if os.environ.get(ConfigConstants.SKIP_CONFIG_PULL_ENV_VAR) is not None:
            return

        if airflow_home is None:
            airflow_home = os.environ[ConfigConstants.AIRFLOW_HOME_ENV_VAR]
        if config_bucket is None:
            config_bucket = os.environ.get(ConfigConstants.CONFIGURATION_BUCKET_NAME)
        if config_bucket_key is None:
            config_bucket_key = os.environ.get(ConfigConstants.CONFIGURATION_BUCKET_KEY)

        os.makedirs(airflow_home, exist_ok=True)
        full_airflow_config_path = os.path.join(airflow_home, "airflow.cfg")

        if config_bucket is not None and config_bucket_key is not None:
            logger.info(f"Pulling s3://{config_bucket}/{config_bucket_key} to {airflow_home}")
            s3_client = boto3.client('s3')
            s3_client.download_file(config_bucket, config_bucket_key, full_airflow_config_path)
            return

        if app_config_name is None:
            app_config_name = os.environ[ConfigConstants.APP_CONFIG_NAME_ENV_VAR]
        if environment is None:
            environment = os.environ[ConfigConstants.ENVIRONMENT_ENV_VAR]
        if application is None:
            application = os.environ[ConfigConstants.APPLICATION_ENV_VAR]

        logger.info(f"Pulling {application}/{environment}/{app_config_name} to {airflow_home}")

        aws_app_config: bytes = parameters.get_app_config(
            name=app_config_name,
            environment=environment,
            application=application,
            force_fetch=True,
            max_age=1000,
        )
        logger.info("Config has been successfully pulled")
        logger.info(f"Start writing the bytes config to a local file: {full_airflow_config_path}")
        with open(full_airflow_config_path, "wb+") as binary_file:
            binary_file.write(aws_app_config)
        logger.info(f"Wrote the Airflow config to {full_airflow_config_path}")
