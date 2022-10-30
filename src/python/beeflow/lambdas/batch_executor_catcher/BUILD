python_sources()

python_awslambda(
    name="package",
    runtime="python3.9",
    handler="batch_executor_catcher.py:handler"
)

docker_image(
    name="docker",
    dependencies = [":package"],
)
