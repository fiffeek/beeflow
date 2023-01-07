import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

TASKS = 100

with DAG(
    dag_id='10s_100t',
    schedule_interval='*/5 * * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    max_active_runs=1,
) as dag:
    run_before_loop = BashOperator(
        task_id='run_before_loop',
        bash_command='echo 1',
    )

    for i in range(TASKS):
        task = BashOperator(
            task_id='runme_' + str(i),
            bash_command='echo "{{ task_instance_key_str }}" && sleep 10',
        )
        run_before_loop >> task
