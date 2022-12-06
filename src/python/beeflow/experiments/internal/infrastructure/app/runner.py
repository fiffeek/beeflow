import logging
import threading
from typing import Optional

import boto3
from beeflow.experiments.internal.adapters.controllers.experiment_controller import (
    ExperimentConfiguration,
    ExperimentController,
    ExperimentControllerConfiguration,
)
from beeflow.experiments.internal.infrastructure.config.config import (
    ApplicationConfiguration,
    ApplicationControllerConfiguration,
    ControllerType,
)
from beeflow.experiments.internal.services.bucket_manager.bucket_manager import BucketManager
from beeflow.experiments.internal.services.dags_manager.beeflow_dags_manager import BeeflowDagsManager
from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from beeflow.experiments.internal.services.dags_manager.mwaa_dags_manager import MWAADagsManager
from rich.progress import Progress


class ExperimentRunner:
    def __init__(self, config: ApplicationConfiguration):
        self.config = config
        self.controllers = [self.__get_controller(controller) for controller in config.controllers]

    def run(self) -> None:
        for experiment in self.config.experiments:
            logging.info(f"Attempting to run {experiment.experiment_id}")
            self.__run_experiment(
                experiment=ExperimentConfiguration(
                    dags_local_path=experiment.dags_local_path,
                    experiment_id=experiment.experiment_id,
                    metrics_collection_time_seconds=experiment.metrics_collection_time_seconds,
                    dag_ids=experiment.dag_ids,
                )
            )

    def __run_experiment(self, experiment: ExperimentConfiguration) -> None:
        threads = []

        with Progress() as progress:
            for controller in self.controllers:
                task_id = progress.add_task(
                    f"Executing experiment {experiment.experiment_id} on {controller.controller_id}...",
                    total=experiment.metrics_collection_time_seconds,
                    start=False,
                    visible=False,
                )
                thread = threading.Thread(
                    target=controller.run_experiment, args=(experiment, progress, task_id)
                )
                threads.append(thread)

            for thread in threads:
                thread.start()

            for thread in threads:
                thread.join()

    @staticmethod
    def __get_controller(controller: ApplicationControllerConfiguration) -> ExperimentController:
        s3_dags_bucket = boto3.resource('s3').Bucket(name=controller.core.dags_bucket.name)
        bucket_manager = BucketManager(
            bucket=s3_dags_bucket, s3_dags_path=controller.core.dags_bucket.dags_path_prefix
        )
        dags_manager: Optional[IDagsManager] = None

        if controller.controller_type == ControllerType.BEEFLOW:
            function_name = controller.type_specific["cli_lambda"]["name"]
            lambda_client = boto3.client('lambda')
            dags_manager = BeeflowDagsManager(function_name=function_name, lambda_client=lambda_client)

        if controller.controller_type == ControllerType.MWAA:
            mwaa_environment_name = controller.type_specific["mwaa"]["environment_name"]
            mwaa_client = boto3.client('mwaa')
            dags_manager = MWAADagsManager(
                mwaa_environment_name=mwaa_environment_name, mwaa_client=mwaa_client
            )

        if dags_manager is None:
            raise ValueError(f"Unknown controller type {controller.controller_type}")

        logging.info(f"Instantiated controller {controller.core.controller_id}")
        return ExperimentController(
            dags_manager=dags_manager,
            bucket_manager=bucket_manager,
            configuration=ExperimentControllerConfiguration(
                controller_id=controller.core.controller_id,
                dags_deletion_time_seconds=controller.core.dags_deletion_time_seconds,
                dags_deployment_wait_seconds=controller.core.dags_deployment_wait_seconds,
                dags_start_wait_time_seconds=controller.core.dags_start_wait_time_seconds,
                export_dag_id=controller.core.export_dag_config.dag_id,
                export_dag_folder_path=controller.core.export_dag_config.dags_local_path,
                export_wait_time_seconds=controller.core.export_dag_config.export_wait_time_seconds,
                dags_creation_cooldown_seconds=controller.core.dags_creation_cooldown_seconds,
            ),
        )
