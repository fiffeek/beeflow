[database]
sql_alchemy_conn = postgresql+psycopg2://${database_user}:${database_password}@${database_endpoint}/${database_name}

[logging]
colored_console_log = false
remote_logging = True
remote_base_log_folder = cloudwatch://${airflow_cloudwatch_logs_group_arn}
remote_log_conn_id = aws_default
