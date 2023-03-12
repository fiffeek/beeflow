import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

TASKS = 32

BATCH_QUEUE = "batch"

with DAG(
    dag_id='10s_32t_30cron',
    schedule_interval='*/30 * * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
) as dag:
    run_before_loop = BashOperator(
        task_id='run_before_loop',
        bash_command='echo 1',
        queue=BATCH_QUEUE,
    )

    for i in range(TASKS):
        task = BashOperator(
            task_id='runme_' + str(i),
            bash_command='echo "{{ task_instance_key_str }}" && sleep 10',
            queue=BATCH_QUEUE,
        )
        run_before_loop >> task
