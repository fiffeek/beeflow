from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DAGsProcessed(BeeflowEvent):
    event_type = BeeflowEventType.DAGS_PROCESSED
