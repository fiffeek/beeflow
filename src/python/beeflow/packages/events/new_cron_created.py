from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class NewCronScheduleCreated(BeeflowEvent):
    event_type = BeeflowEventType.NEW_CRON_CREATED
    dag_id: str
    rule_id: str
