from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class MigrationCompleted(BeeflowEvent):
    event_type = BeeflowEventType.MIGRATION_COMPLETED
