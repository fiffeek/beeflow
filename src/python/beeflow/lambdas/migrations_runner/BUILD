python_sources()

python_awslambda(
    name="package",
    runtime="python3.9",
    handler="main.py:handler",
    dependencies=[
        "src/python/beeflow/packages/config:config"
    ]
)
