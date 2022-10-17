from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class TaskInstanceQueued(BeeflowEvent):
    event_type = BeeflowEventType.TASK_INSTANCE_QUEUED
    dag_id: str
    run_id: str
    task_id: str
    map_index: int
    try_number: int
    pool: str
    queue: str
