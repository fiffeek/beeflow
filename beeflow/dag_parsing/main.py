from airflow.operators.bash import BashOperator

from beeflow.common.integer_sum import integer_sum


def main():
    print("Hello, world!")
    print(integer_sum(1, 2))

    run_this = BashOperator(
        task_id='run_after_loop',
        bash_command='echo 1',
    )


if __name__ == "__main__":
    main()
