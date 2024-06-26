from typing import Any, Dict

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.parser.models import SqsModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.lambdas.scheduler.scheduler_job import BeeflowSchedulerJob

logger = Logger()


@logger.inject_lambda_context
@event_parser(model=SqsModel)
def handler(event: SqsModel, context: LambdaContext) -> Dict[str, Any]:
    records = len(event.Records)
    job = BeeflowSchedulerJob(
        num_runs=records,
        scheduler_idle_sleep_time=0,
    )
    job.run()
    return {}
