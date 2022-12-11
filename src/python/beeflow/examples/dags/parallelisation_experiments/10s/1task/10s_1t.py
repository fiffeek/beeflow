import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='10s_1t',
    schedule_interval='*/5 * * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
) as dag:
    run_before_loop = BashOperator(
        task_id='run_before_loop',
        bash_command='echo "{{ task_instance_key_str }}" && sleep 10',
    )
