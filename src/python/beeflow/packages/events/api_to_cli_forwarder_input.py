from typing import List

from beeflow.packages.events.beeflow_event import BeeflowEvent
from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class APIToCLIForwarderInput(BeeflowEvent):
    event_type = BeeflowEventType.API_TO_CLI_FORWARDER_INPUT
    args: List[str]
