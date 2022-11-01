python_sources(
    dependencies = [
        "src/python/beeflow/packages/database/migrations:migrations",
        ":alembic_config",
    ],
    skip_black = True,
    skip_docformatter = True,
    skip_flake8 = True,
    skip_isort = True,
    skip_mypy = True,
)

resource(
    name = "alembic_config",
    source = "alembic.ini",
)
