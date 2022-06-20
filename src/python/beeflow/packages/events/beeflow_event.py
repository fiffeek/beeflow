from aws_lambda_powertools.utilities.parser import BaseModel

from beeflow.packages.events.beeflow_event_type import BeeflowEventType


class BeeflowEvent(BaseModel):
    event_type: BeeflowEventType

    class Config:
        use_enum_values = True
