python_sources(
    name="package",
    dependencies=[
        "src/python/beeflow/packages/config:config"
    ]
)

pex_binary(
    name="bin",
    entry_point="webserver.py",
    dependencies=[":package"]
)

docker_image(
    name="docker",
    dependencies = [":bin"],
)
