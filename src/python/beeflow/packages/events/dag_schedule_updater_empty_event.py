from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DAGScheduleUpdaterEmptyEvent(BeeflowEvent):
    event_type = BeeflowEventType.DAG_SCHEDULE_UPDATER_EMPTY
