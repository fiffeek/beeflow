from enum import Enum


class BeeflowEventType(str, Enum):
    MIGRATION_COMPLETED = 'migration_completed'
    TRIGGER_DAGS_PROCESSING_COMMAND = 'trigger_dags_processing_command'
    DAGS_PROCESSING_TRIGGERED = 'dags_processing_triggered'
    DAGS_PROCESSED = 'dags_processed'
    CDC_INPUT = 'cdc_input'
    NEW_CRON_CREATED = 'new_cron_created'
    DAG_CRON_TRIGGERED = 'dag_cron_triggered'
    DAG_SCHEDULE_UPDATER_EMPTY = 'dag_schedule_updater_empty'

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

    # DB DAG run events
    DAG_RUN_SUCCESS = 'dag_run_success'
    DAG_RUN_FAILED = 'dag_run_failed'
    DAG_RUN_RUNNING = 'dag_run_running'
