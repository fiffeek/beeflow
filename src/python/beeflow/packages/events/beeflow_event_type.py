from enum import Enum


class BeeflowEventType(str, Enum):
    MIGRATION_COMPLETED = 'migration_completed'
    DAGS_PROCESSING_TRIGGERED = 'dags_processing_triggered'
    DAGS_PROCESSED = 'dags_processed'
    CDC_INPUT = 'cdc_input'

    # DB DAG events
    DAG_CREATED = 'dag_created'
    DAG_UPDATED = 'dag_updated'

    # DB Task instance events
    TASK_INSTANCE_QUEUED = 'task_instance_queued'
    TASK_INSTANCE_FAILED = 'task_instance_failed'
    TASK_INSTANCE_SUCCESS = 'task_instance_success'
    TASK_INSTANCE_SKIPPED = 'task_instance_skipped'
    TASK_INSTANCE_UNKNOWN = 'task_instance_unknown'
    TASK_INSTANCE_RUNNING = 'task_instance_running'
    TASK_INSTANCE_UP_FOR_RETRY = 'task_instance_up_for_retry'
    TASK_INSTANCE_RESTARTING = 'task_instance_restarting'
    TASK_INSTANCE_SHUTDOWN = 'task_instance_shutdown'
    TASK_INSTANCE_UPSTREAM_FAILED = 'task_instance_upstream_failed'
