import time
from dataclasses import dataclass
from typing import List

from beeflow.experiments.internal.services.bucket_manager.bucket_manager import IBucketManager
from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from rich.progress import Progress, TaskID, track


@dataclass
class ExperimentConfiguration:
    dags_absolute_path: str
    dag_ids: List[str]
    metrics_collection_time_seconds: int
    experiment_id: str


@dataclass
class ExperimentControllerConfiguration:
    dags_deletion_time_seconds: int
    dags_deployment_wait_seconds: int
    dags_start_wait_time_seconds: int
    controller_id: str


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
        self, configuration: ExperimentConfiguration, progress: Progress, task_id: TaskID
    ) -> None:
        self.__create_dags(configuration)
        self.__start_dags(configuration)
        self.__collect_metrics(configuration, progress, task_id)
        self.__clean_up(configuration)
        self.dags_manager.export_metrics()

    def __clean_up(self, configuration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.stop_dag(dag_id=dag_id)
        self.bucket_manager.clear_dags()

    @staticmethod
    def __collect_metrics(configuration, progress: Progress, task_id: TaskID):
        for _ in range(configuration.metrics_collection_time_seconds):
            time.sleep(1)
            progress.update(task_id, advance=1)

    def __start_dags(self, configuration):
        for dag_id in configuration.dag_ids:
            self.dags_manager.start_dag(dag_id=dag_id)
        time.sleep(self.configuration.dags_start_wait_time_seconds)

    def __create_dags(self, configuration):
        self.bucket_manager.clear_dags()
        time.sleep(self.configuration.dags_deletion_time_seconds)
        self.bucket_manager.publish_experiment(configuration.dags_absolute_path)
        for dag_id in configuration.dag_ids:
            self.dags_manager.wait_until_dag_exists(
                dag_id=dag_id, timeout_seconds=self.configuration.dags_deployment_wait_seconds
            )
