[database]
sql_alchemy_conn = postgresql+psycopg2://${database_user}:${database_password}@${database_endpoint}/${database_name}

[logging]
colored_console_log = false
remote_logging = True
remote_base_log_folder = s3://${airflow_logs_bucket_name}/${airflow_logs_bucket_key}
remote_log_conn_id = aws_default
encrypt_s3_logs = False
