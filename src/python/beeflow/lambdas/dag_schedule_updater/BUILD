python_sources()

python_awslambda(
    name="package",
    runtime="python3.9",
    handler="dag_schedule_updater.py:handler",
    dependencies=[
        "src/python/beeflow/packages/config:config"
    ]
)

docker_image(
    name="docker",
    dependencies = [":package"],
)
