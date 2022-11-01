from typing import Any, Dict

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class CDCInput(BeeflowEvent):
    event_type = BeeflowEventType.CDC_INPUT
    metadata: Dict[str, Any]
