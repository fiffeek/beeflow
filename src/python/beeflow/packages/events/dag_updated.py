from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DAGUpdatedEvent(BeeflowEvent):
    event_type = BeeflowEventType.DAG_UPDATED
    dag_id: str
    is_paused: bool
    is_active: bool
