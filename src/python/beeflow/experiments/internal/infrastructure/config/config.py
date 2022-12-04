from dataclasses import dataclass
from enum import Enum
from typing import Any, Dict, List

from dataclasses_json import dataclass_json


class ControllerType(Enum):
    BEEFLOW = "beeflow"


@dataclass_json
@dataclass
class ApplicationControllerCoreDagsBucketConfiguration:
    name: str
    region: str


@dataclass_json
@dataclass
class ApplicationControllerCoreConfiguration:
    dags_deletion_time_seconds: int
    dags_deployment_wait_seconds: int
    dags_start_wait_time_seconds: int
    controller_id: str
    dags_bucket: ApplicationControllerCoreDagsBucketConfiguration


@dataclass_json
@dataclass
class ApplicationControllerConfiguration:
    core: ApplicationControllerCoreConfiguration
    controller_type: ControllerType
    type_specific: Dict[str, Any]


@dataclass_json
@dataclass
class ApplicationExperimentConfiguration:
    dags_absolute_local_path: str
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
            self.config = ApplicationConfiguration.from_json(config_file.read())
