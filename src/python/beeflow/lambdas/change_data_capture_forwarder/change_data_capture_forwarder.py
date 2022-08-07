from typing import Dict, Any

from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.events.cdc_input import CDCInput
from aws_lambda_powertools import Logger

logger = Logger()


@event_parser(model=CDCInput)
@logger.inject_lambda_context
def handler(event: CDCInput, context: LambdaContext) -> Dict[str, Any]:
    logger.info(f"Got event {event}")
    return {
        "lambda_request_id": context.aws_request_id,
        "lambda_arn": context.invoked_function_arn,
    }
