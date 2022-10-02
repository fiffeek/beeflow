from aws_lambda_powertools import Logger

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.cdc_input import CDCInput
from beeflow.packages.events.dag_updated import DAGUpdatedEvent
from beeflow.packages.events.task_instance_failed import TaskInstanceFailed
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued
from beeflow.packages.events.task_instance_restarting import TaskInstanceRestarting
from beeflow.packages.events.task_instance_running import TaskInstanceRunning
from beeflow.packages.events.task_instance_shutdown import TaskInstanceShutdown
from beeflow.packages.events.task_instance_skipped import TaskInstanceSkipped
from beeflow.packages.events.task_instance_success import TaskInstanceSuccess
from beeflow.packages.events.task_instance_unknown import TaskInstanceUnknown
from beeflow.packages.events.task_instance_upstream_failed import TaskInstanceUpstreamFailed

logger = Logger()


class DatabasePassthroughEventConverter:

    def __init__(self, event: CDCInput):
        self.event = event
        self.metadata = self.event.metadata

    def __is_task_instance_event(self) -> bool:
        required_fields = ["task_id",
                           "dag_id",
                           "run_id",
                           "state",
                           "operator",
                           "max_tries",
                           "queue",
                           "pool",
                           "try_number",
                           "map_index"]
        for field in required_fields:
            if field not in self.metadata:
                logger.info(f"Event cannot be identified as Task Instance event as {field} is missing")
                return False
        return True

    def __is_dag_event(self) -> bool:
        required_fields = ["dag_id", "is_paused", "is_active"]
        for field in required_fields:
            if field not in self.metadata:
                logger.info(f"Event cannot be identified as DAG event as {field} is missing")
                return False
        return True

    def __convert_to_task_instance_event(self) -> BeeflowEvent:
        if self.metadata["state"] == "queued":
            return TaskInstanceQueued(dag_id=self.metadata["dag_id"],
                                      run_id=self.metadata["run_id"],
                                      task_id=self.metadata["task_id"],
                                      map_index=self.metadata["map_index"],
                                      pool=self.metadata["pool"],
                                      try_number=self.metadata["try_number"])
        if self.metadata["state"] == "failed":
            return TaskInstanceFailed(dag_id=self.metadata["dag_id"],
                                      run_id=self.metadata["run_id"],
                                      task_id=self.metadata["task_id"],
                                      map_index=self.metadata["map_index"],
                                      try_number=self.metadata["try_number"])
        if self.metadata["state"] == "upstream_failed":
            return TaskInstanceUpstreamFailed(dag_id=self.metadata["dag_id"],
                                              run_id=self.metadata["run_id"],
                                              task_id=self.metadata["task_id"],
                                              try_number=self.metadata["try_number"])
        if self.metadata["state"] == "success":
            return TaskInstanceSuccess(dag_id=self.metadata["dag_id"],
                                       run_id=self.metadata["run_id"],
                                       task_id=self.metadata["task_id"],
                                       map_index=self.metadata["map_index"],
                                       try_number=self.metadata["try_number"])
        if self.metadata["state"] == "skipped":
            return TaskInstanceSkipped(dag_id=self.metadata["dag_id"],
                                       run_id=self.metadata["run_id"],
                                       task_id=self.metadata["task_id"],
                                       try_number=self.metadata["try_number"])
        if self.metadata["state"] == "running":
            return TaskInstanceRunning(dag_id=self.metadata["dag_id"],
                                       run_id=self.metadata["run_id"],
                                       task_id=self.metadata["task_id"])
        if self.metadata["state"] == "restarting":
            return TaskInstanceRestarting(dag_id=self.metadata["dag_id"],
                                          run_id=self.metadata["run_id"],
                                          task_id=self.metadata["task_id"])
        if self.metadata["state"] == "shutdown":
            return TaskInstanceShutdown(dag_id=self.metadata["dag_id"],
                                        run_id=self.metadata["run_id"],
                                        task_id=self.metadata["task_id"])
        if self.metadata["state"] is None:
            return TaskInstanceUnknown(dag_id=self.metadata["dag_id"],
                                       run_id=self.metadata["run_id"],
                                       task_id=self.metadata["task_id"])

        raise ValueError(f"State {self.metadata['state']} unknown")

    def __convert_to_dag_event(self) -> BeeflowEvent:
        return DAGUpdatedEvent(dag_id=self.metadata["dag_id"],
                               is_active=self.metadata["is_active"],
                               is_paused=self.metadata["is_paused"])

    def convert(self) -> BeeflowEvent:
        if self.__is_task_instance_event():
            return self.__convert_to_task_instance_event()
        if self.__is_dag_event():
            return self.__convert_to_dag_event()
        raise ValueError(f"The input event {self.event} cannot be converted to a Beeflow event")
