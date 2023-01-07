import os
from dataclasses import dataclass
from enum import Enum
from typing import Any, Dict, List, Optional

from dataclasses_json import dataclass_json


class ControllerType(Enum):
    BEEFLOW = "beeflow"
    MWAA = "mwaa"


@dataclass_json
@dataclass
class ApplicationControllerCoreDagsBucketConfiguration:
    name: str
    region: str
    dags_path_prefix: Optional[str] = None


@dataclass_json
@dataclass
class ApplicationControllerExportDagConfiguration:
    dags_local_path: str
    dag_id: str
    export_wait_time_seconds: int


@dataclass_json
@dataclass
class ApplicationControllerCoreConfiguration:
    dags_deletion_time_seconds: int
    dags_deployment_wait_seconds: int
    dags_start_wait_time_seconds: int
    controller_id: str
    dags_bucket: ApplicationControllerCoreDagsBucketConfiguration
    export_dag_config: ApplicationControllerExportDagConfiguration
    dags_creation_cooldown_seconds: int = 0


@dataclass_json
@dataclass
class ApplicationControllerConfiguration:
    core: ApplicationControllerCoreConfiguration
    controller_type: ControllerType
    type_specific: Dict[str, Any]
    default_pool_size: int = 256


@dataclass_json
@dataclass
class ApplicationExperimentConfiguration:
    dags_local_path: str
    dag_ids: List[str]
    metrics_collection_time_seconds: int
    experiment_id: str


@dataclass_json
@dataclass
class ApplicationConfiguration:
    controllers: List[ApplicationControllerConfiguration]
    experiments: List[ApplicationExperimentConfiguration]


class ExperimentConfiguration:
    def __init__(self, config_path: str):
        with open(config_path) as config_file:
            self.config = ApplicationConfiguration.from_json(config_file.read())  # type: ignore[attr-defined]
        self.__validate_configuration()

    def __validate_configuration(self) -> None:
        for experiment in self.config.experiments:
            self.__validate_experiment(experiment)
        for controller in self.config.controllers:
            self.__validate_controller(controller)

    @staticmethod
    def __validate_experiment(experiment: ApplicationExperimentConfiguration) -> None:
        if not os.path.isdir(experiment.dags_local_path):
            raise ValueError(
                f"Dag's path {experiment.dags_local_path} is not "
                f"a valid directory for {experiment.experiment_id}"
            )

    @staticmethod
    def __validate_controller(controller: ApplicationControllerConfiguration) -> None:
        if not os.path.isdir(controller.core.export_dag_config.dags_local_path):
            raise ValueError(
                f"Dag's path {controller.core.export_dag_config.dags_local_path} "
                f"is not a valid directory for DAG exporter in {controller.core.controller_id}"
            )
