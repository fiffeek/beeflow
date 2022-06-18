from typing import Any, Dict

from airflow.utils import db
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:

    logger.info("Triggering Airflow's migrations.")
    db.upgradedb()
    logger.info("Finished running migrations")

    return event
