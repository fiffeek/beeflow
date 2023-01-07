[database]
sql_alchemy_conn = postgresql+psycopg2://${database_user}:${database_password}@${database_endpoint}/${database_name}

[logging]
colored_console_log = false
remote_logging = True
%{ if logging_type == "s3" }
remote_base_log_folder = s3://${airflow_logs_bucket_name}/${airflow_logs_bucket_key}
encrypt_s3_logs = False
%{ endif }
%{ if logging_type == "cloudwatch" }
remote_base_log_folder = cloudwatch://${airflow_cloudwatch_logs_group_arn}
%{ endif }
remote_log_conn_id = aws_default

[scheduler]
schedule_after_task_execution = False

[core]
load_examples = false
parallelism = 512
max_active_tasks_per_dag = 512
default_pool_task_slot_count = 256

[operators]
default_queue = lambda
