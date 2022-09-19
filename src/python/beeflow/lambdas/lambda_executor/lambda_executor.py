from typing import Dict, Any, List

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import envelopes, event_parser
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


@logger.inject_lambda_context
@event_parser(model=TaskInstanceQueued, envelope=envelopes.SqsEnvelope)
def handler(events: List[TaskInstanceQueued], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    for event in events:
        logger.info(f"Executing {event.task_id} from {event.dag_id}")
    return {}
