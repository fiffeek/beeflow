python_sources()

python_awslambda(
    name="package",
    runtime="python3.9",
    handler="lambda_executor.py:handler",
    dependencies=[
        "src/python/beeflow/packages/config:config"
    ]
)

docker_image(
    name="docker",
    dependencies = [":package"],
)
