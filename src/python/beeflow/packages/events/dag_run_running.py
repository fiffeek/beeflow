from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class DagRunRunning(BeeflowEvent):
    event_type = BeeflowEventType.DAG_RUN_RUNNING
    dag_id: str
    dag_hash: str
    run_id: str
    run_type: str
