from typing import Any, Dict

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.packages.dag_parsing.agent import get_agent
from beeflow.packages.events.dags_processed import DAGsProcessed

logger = Logger()


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    logger.info("Starting a single ProcessorAgent parsing loop.")

    processor_agent = get_agent()
    processor_agent.start()
    processor_agent.run_single_parsing_loop()
    processor_agent.wait_until_finished()
    processor_agent.end()

    logger.info("Finished a single ProcessorAgent parsing loop.")

    return DAGsProcessed().dict()
