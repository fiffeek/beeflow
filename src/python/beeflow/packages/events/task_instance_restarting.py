from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class TaskInstanceRestarting(BeeflowEvent):
    event_type = BeeflowEventType.TASK_INSTANCE_RESTARTING
    dag_id: str
    run_id: str
    task_id: str
