from typing import Dict, Any

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DAGCreatedEvent(BeeflowEvent):
    event_type = BeeflowEventType.DAG_CREATED
    dag_id: str
