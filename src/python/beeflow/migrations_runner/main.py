from typing import Dict, Any

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from airflow.utils import db


logger = Logger(service="payment")


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    logger.info(f"Triggering Airflow's migrations.")
    db.upgradedb()
    return event
