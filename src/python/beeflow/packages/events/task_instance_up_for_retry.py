from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class TaskInstanceUpForRetry(BeeflowEvent):
    event_type = BeeflowEventType.TASK_INSTANCE_UP_FOR_RETRY
    dag_id: str
    run_id: str
    task_id: str
    map_index: int
    try_number: int
