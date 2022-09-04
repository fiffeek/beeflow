from enum import Enum


class BeeflowEventType(str, Enum):
    MIGRATION_COMPLETED = 'migration_completed'
    DAGS_PROCESSING_TRIGGERED = 'dags_processing_triggered'
    DAGS_PROCESSED = 'dags_processed'
    CDC_INPUT = 'cdc_input'
    DAG_CREATED = 'dag_created'
    TASK_INSTANCE_QUEUED = 'task_instance_queued'
    TASK_INSTANCE_FAILED = 'task_instance_failed'
