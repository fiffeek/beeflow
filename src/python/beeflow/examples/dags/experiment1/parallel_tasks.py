import datetime

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

LAMBDA_QUEUE = "lambda"

with DAG(
    dag_id='beeflow_parallel_tasks_runner',
    schedule_interval='*/5 * * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    dagrun_timeout=datetime.timedelta(minutes=60),
) as dag:
    # [START howto_operator_bash]
    run_this = BashOperator(
        task_id='run_after_loop',
        bash_command='echo 1',
        queue=LAMBDA_QUEUE,
    )
    # [END howto_operator_bash]

    for i in range(3):
        task = BashOperator(
            task_id='runme_' + str(i),
            bash_command='echo "{{ task_instance_key_str }}" && sleep 10',
            queue=LAMBDA_QUEUE,
        )
        task >> run_this
