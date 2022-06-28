import os

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities import parameters

logger = Logger()


class Configuration:
    APP_CONFIG_NAME_ENV_VAR = "BEEFLOW__APP_CONFIG_NAME"
    ENVIRONMENT_ENV_VAR = "BEEFLOW__ENVIRONMENT"
    APPLICATION_ENV_VAR = "BEEFLOW__APPLICATION"
    DAGS_BUCKET_ENV_VAR = "BEEFLOW__DAGS_BUCKET_NAME"
    AIRFLOW_HOME_ENV_VAR = "AIRFLOW_HOME"

    @staticmethod
    def load(app_config_name=None, environment=None, application=None, airflow_home=None):
        if app_config_name is None:
            app_config_name = os.environ[Configuration.APP_CONFIG_NAME_ENV_VAR]
        if environment is None:
            environment = os.environ[Configuration.ENVIRONMENT_ENV_VAR]
        if application is None:
            application = os.environ[Configuration.APPLICATION_ENV_VAR]
        if airflow_home is None:
            airflow_home = os.environ[Configuration.AIRFLOW_HOME_ENV_VAR]

        logger.info(f"Pulling {application}/{environment}/{app_config_name} to {airflow_home}")

        aws_app_config: bytes = parameters.get_app_config(
            name=app_config_name,
            environment=environment,
            application=application,
            force_fetch=True,
            max_age=1000,
        )
        logger.info("Config has been successfully pulled")

        full_airflow_config_path = os.path.join(airflow_home, "airflow.cfg")
        logger.info(f"Start writing the bytes config to a local file: {full_airflow_config_path}")
        os.makedirs(airflow_home, exist_ok=True)
        with open(full_airflow_config_path, "wb+") as binary_file:
            binary_file.write(aws_app_config)
        logger.info(f"Wrote the Airflow config to {full_airflow_config_path}")
