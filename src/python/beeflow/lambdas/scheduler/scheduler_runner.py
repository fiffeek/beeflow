from typing import Dict, Any

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.lambdas.scheduler.scheduler_job import SchedulerJob

logger = Logger()


@logger.inject_lambda_context
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    job = SchedulerJob(
        num_runs=1,
    )
    job.run()
    return {}