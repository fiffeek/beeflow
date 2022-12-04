import logging
import time
from dataclasses import dataclass
from typing import List

from beeflow.experiments.internal.services.bucket_manager.bucket_manager import IBucketManager
from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from rich.progress import Progress, TaskID, track


@dataclass
class ExperimentConfiguration:
    dags_local_path: str
    dag_ids: List[str]
    metrics_collection_time_seconds: int
    experiment_id: str


@dataclass
class ExperimentControllerConfiguration:
    dags_deletion_time_seconds: int
    dags_deployment_wait_seconds: int
    dags_start_wait_time_seconds: int
    controller_id: str
    export_dag_id: str
    export_dag_folder_path: str
    export_wait_time_seconds: int


class ExperimentController:
    def __init__(
        self,
        bucket_manager: IBucketManager,
        dags_manager: IDagsManager,
        configuration: ExperimentControllerConfiguration,
    ):
        self.bucket_manager = bucket_manager
        self.dags_manager = dags_manager
        self.configuration = configuration

    @property
    def controller_id(self):
        return self.configuration.controller_id

    def run_experiment(
        self, experiment_configuration: ExperimentConfiguration, progress: Progress, task_id: TaskID
    ) -> None:
        self.__create_dags(experiment_configuration)
        self.__start_dags(experiment_configuration)
        self.__collect_metrics(experiment_configuration, progress, task_id)
        self.__stop_dags(experiment_configuration)
        self.__export_metrics()
        self.__clean_up()

    def __stop_dags(self, configuration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.stop_dag(dag_id=dag_id)

    @staticmethod
    def __collect_metrics(configuration, progress: Progress, task_id: TaskID):
        logging.info(f"Collecting metrics for {configuration.metrics_collection_time_seconds} seconds")
        progress.start_task(task_id)

        for _ in range(configuration.metrics_collection_time_seconds):
            time.sleep(1)
            progress.update(task_id, advance=1)

        progress.stop_task(task_id)
        progress.remove_task(task_id)
        logging.info("Metrics collected")

    def __start_dags(self, configuration: ExperimentConfiguration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.start_dag(dag_id=dag_id)
            logging.info(f"Started DAG {dag_id}")
        logging.info(f"Waiting for {self.configuration.dags_start_wait_time_seconds}")
        time.sleep(self.configuration.dags_start_wait_time_seconds)

    def __create_dags(self, configuration: ExperimentConfiguration):
        self.bucket_manager.clear_dags()
        logging.info(
            f"Cleaning Previous DAGs in case bucket is not clean,"
            f" sleep for {self.configuration.dags_deletion_time_seconds}"
        )
        time.sleep(self.configuration.dags_deletion_time_seconds)

        self.bucket_manager.publish_dags(configuration.dags_local_path)
        logging.info("Dags published")

        for dag_id in configuration.dag_ids:
            logging.info(f"Waiting for DAG {dag_id} to become available in Airflow")
            self.dags_manager.wait_until_dag_exists(
                dag_id=dag_id, timeout_seconds=self.configuration.dags_deployment_wait_seconds
            )

    def __export_metrics(self):
        logging.info("Attempting to publish collected metrics")
        self.bucket_manager.publish_dags(self.configuration.export_dag_folder_path)
        self.dags_manager.wait_until_dag_exists(
            dag_id=self.configuration.export_dag_id,
            timeout_seconds=self.configuration.dags_deployment_wait_seconds,
        )
        self.dags_manager.start_dag(dag_id=self.configuration.export_dag_id)
        self.dags_manager.export_metrics(export_dag_id=self.configuration.export_dag_id)
        time.sleep(self.configuration.export_wait_time_seconds)

        self.dags_manager.stop_dag(dag_id=self.configuration.export_dag_id)
        logging.info("Metrics successfully exported")

    def __clean_up(self):
        logging.info("Cleaning up data after experimentation")
        self.bucket_manager.clear_dags()
        time.sleep(self.configuration.dags_deletion_time_seconds)
