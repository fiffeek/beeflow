from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class TriggerDAGsProcessingCommand(BeeflowEvent):
    event_type = BeeflowEventType.TRIGGER_DAGS_PROCESSING_COMMAND
