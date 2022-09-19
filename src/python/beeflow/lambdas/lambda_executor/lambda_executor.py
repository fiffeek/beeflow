from typing import Dict, Any, List

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import parse, envelopes, event_parser
from aws_lambda_powertools.utilities.parser.models import EventBridgeModel
from aws_lambda_powertools.utilities.typing import LambdaContext

from beeflow.packages.dags_downloader.dags_downloader import DagsDownloader
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued

logger = Logger()


@logger.inject_lambda_context
@event_parser(model=EventBridgeModel, envelope=envelopes.SqsEnvelope)
def handler(events: List[EventBridgeModel], context: LambdaContext) -> Dict[str, Any]:
    DagsDownloader().download_dags()
    for event in events:
        parsed_event: TaskInstanceQueued = parse(event=event.detail, model=TaskInstanceQueued)
        logger.info(f"Executing {parsed_event.task_id} from {parsed_event.dag_id}")
    return {}
