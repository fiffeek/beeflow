import logging
from dataclasses import dataclass
from typing import List

from beeflow.experiments.internal.services.bucket_manager.bucket_manager import IBucketManager
from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from beeflow.packages.progress.task_bar import sleep
from rich.progress import Progress, TaskID


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
        self.__create_dags(experiment_configuration, progress)
        self.__start_dags(experiment_configuration, progress)
        self.__collect_metrics(experiment_configuration, progress, task_id)
        self.__stop_dags(experiment_configuration)
        self.__export_metrics(progress)
        self.__delete_dags(experiment_configuration)
        self.__clean_up(progress)

    def __stop_dags(self, configuration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.stop_dag(dag_id=dag_id)

    @staticmethod
    def __collect_metrics(configuration, progress: Progress, task_id: TaskID):
        logging.info(f"Collecting metrics for {configuration.metrics_collection_time_seconds} seconds")

        progress.update(task_id, visible=True)
        progress.start_task(task_id)

        sleep(seconds=configuration.metrics_collection_time_seconds, progress=progress, task_id=task_id)

        progress.stop_task(task_id)
        progress.remove_task(task_id)

        logging.info("Metrics collected")

    def __start_dags(self, configuration: ExperimentConfiguration, progress: Progress):
        for dag_id in configuration.dag_ids:
            self.dags_manager.start_dag(dag_id=dag_id)
            logging.info(f"Started DAG {dag_id}")
        sleep(
            seconds=self.configuration.dags_start_wait_time_seconds,
            progress=progress,
            task_description=f"[{self.controller_id}] Waiting for DAGs to start up",
        )

    def __create_dags(self, configuration: ExperimentConfiguration, progress: Progress):
        logging.info("Attempting to remove DAGs in case previous experiment had left overs")
        self.__try_delete_dags(configuration)

        self.bucket_manager.clear_dags()
        sleep(
            seconds=self.configuration.dags_deletion_time_seconds,
            progress=progress,
            task_description=f"[{self.controller_id}] Cleaning Previous DAGs in case bucket is not clean",
        )

        self.bucket_manager.publish_dags(configuration.dags_local_path)
        logging.info("Dags published")

        for dag_id in configuration.dag_ids:
            logging.info(f"Waiting for DAG {dag_id} to become available in Airflow")
            self.dags_manager.wait_until_dag_exists(
                dag_id=dag_id, timeout_seconds=self.configuration.dags_deployment_wait_seconds
            )

    def __export_metrics(self, progress: Progress):
        logging.info("Attempting to publish collected metrics")
        self.bucket_manager.publish_dags(self.configuration.export_dag_folder_path)
        self.dags_manager.wait_until_dag_exists(
            dag_id=self.configuration.export_dag_id,
            timeout_seconds=self.configuration.dags_deployment_wait_seconds,
        )
        logging.info(f"Starting DAG {self.configuration.export_dag_id}")
        self.dags_manager.start_dag(dag_id=self.configuration.export_dag_id)
        logging.info(f"Triggering DAG {self.configuration.export_dag_id}")
        self.dags_manager.trigger_dag(dag_id=self.configuration.export_dag_id)
        sleep(
            seconds=self.configuration.export_wait_time_seconds,
            progress=progress,
            task_description=f"[{self.controller_id}] Waiting for export to finish",
        )

        self.dags_manager.stop_dag(dag_id=self.configuration.export_dag_id)
        self.dags_manager.delete_dag(dag_id=self.configuration.export_dag_id)
        logging.info("Metrics successfully exported")

    def __clean_up(self, progress: Progress):
        logging.info("Cleaning up data after experimentation")
        self.bucket_manager.clear_dags()
        sleep(
            seconds=self.configuration.dags_deletion_time_seconds,
            progress=progress,
            task_description=f"[{self.controller_id}] Cleaning up data after experimentation",
        )

    def __delete_dags(self, configuration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.delete_dag(dag_id=dag_id)

    def __try_delete_dags(self, configuration):
        for dag_id in configuration.dag_ids:
            try:
                self.dags_manager.delete_dag(dag_id=dag_id)
            except Exception:
                logging.warning(f"Swallowing errors on dags deletion for {dag_id}")
