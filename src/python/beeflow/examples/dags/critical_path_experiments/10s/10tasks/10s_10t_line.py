import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

TASKS = 10

with DAG(
    dag_id=f'10s_{TASKS}t_line',
    schedule_interval='*/5 * * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
) as dag:
    tasks = [
        BashOperator(
            task_id='runme_' + str(i),
            bash_command='echo "{{ task_instance_key_str }}" && sleep 10',
            dag=dag,
        )
        for i in range(TASKS)
    ]

    for i in range(TASKS):
        if i == 0:
            continue
        tasks[i - 1] >> tasks[i]
