from typing import Any, Dict

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.cli.cli_parser import get_parser
from beeflow.packages.events.api_to_cli_forwarder_input import APIToCLIForwarderInput

logger = Logger()


@logger.inject_lambda_context
@event_parser(model=APIToCLIForwarderInput)
def handler(event: APIToCLIForwarderInput, context: LambdaContext) -> Dict[str, Any]:
    logger.info("Running arguments parser on the incoming data")
    parser = get_parser()
    args = parser.parse_args(event.args)
    args.func(args)
    logger.info("Finished running the command")
    return {}
