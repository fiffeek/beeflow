from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DagRunQueued(BeeflowEvent):
    event_type = BeeflowEventType.DAG_RUN_QUEUED
    dag_id: str
    dag_hash: str
    run_id: str
    run_type: str
