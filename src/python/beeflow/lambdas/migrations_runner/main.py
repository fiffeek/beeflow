from typing import Any, Dict

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.database import db
from beeflow.packages.events.migration_completed import MigrationCompleted

logger = Logger()


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:

    logger.info("Triggering Airflow's migrations.")
    if "downgrade_to" in event:
        db.downgrade(to_revision=event["downgrade_to"])
    db.upgradedb()
    logger.info("Finished running migrations")

    return MigrationCompleted().dict()
