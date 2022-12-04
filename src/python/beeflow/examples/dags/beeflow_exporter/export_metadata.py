import csv
import os
from datetime import datetime
from io import StringIO

import pendulum
from airflow import DAG, settings
from airflow.models import DagRun, TaskFail, TaskInstance
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.utils.session import create_session

MAX_AGE_IN_DAYS = 30

OBJECTS_TO_EXPORT = [
    [DagRun, DagRun.execution_date],
    [TaskFail, TaskFail.start_date],
    [TaskInstance, TaskInstance.execution_date],
]


def export_db_fn():
    s3_bucket = os.environ["BEEFLOW__EXTRACT_METADATA_S3_BUCKET"]
    s3_bucket_prefix = os.environ["BEEFLOW__EXTRACT_METADATA_S3_PREFIX"]

    with create_session() as session:
        s3_folder_name = datetime.today().strftime('%Y-%m-%d_%H-%M')
        oldest_date = pendulum.today('UTC').add(days=-MAX_AGE_IN_DAYS)

        s3_hook = S3Hook()
        s3_client = s3_hook.get_conn()

        for table_name, execution_date in OBJECTS_TO_EXPORT:
            query = session.query(table_name).filter(execution_date >= oldest_date)

            all_rows = query.all()
            name = table_name.__name__.lower()

            if len(all_rows) > 0:
                out_file_string = ""

                extract_file = StringIO(out_file_string)
                extract_file_writer = csv.DictWriter(extract_file, vars(all_rows[0]).keys())
                extract_file_writer.writeheader()

                for row in all_rows:
                    extract_file_writer.writerow(vars(row))

                S3_KEY = s3_bucket_prefix + '/export/' + name + '/dt=' + s3_folder_name + '/' + name + '.csv'
                s3_client.put_object(Bucket=s3_bucket, Key=S3_KEY, Body=extract_file.getvalue())


with DAG(
    dag_id='db_export_dag', schedule_interval=None, catchup=False, start_date=datetime(2022, 2, 18)
) as dag:
    export_db = PythonOperator(task_id='export_db', python_callable=export_db_fn)
