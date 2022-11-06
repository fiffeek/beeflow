from typing import Any, Dict

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.parser.models import SqsModel
from aws_lambda_powertools.utilities.typing import LambdaContext
from beeflow.lambdas.scheduler.scheduler_job import SchedulerJob

logger = Logger()


@logger.inject_lambda_context
@event_parser(model=SqsModel)
def handler(event: SqsModel, context: LambdaContext) -> Dict[str, Any]:
    records = len(event.Records)
    job = SchedulerJob(
        num_runs=records,
    )
    job.run()
    return {}
