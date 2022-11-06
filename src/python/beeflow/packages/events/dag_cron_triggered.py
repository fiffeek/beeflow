from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DAGCronTriggered(BeeflowEvent):
    event_type = BeeflowEventType.DAG_CRON_TRIGGERED
    dag_id: str
    trigger_time: str
