from unittest import mock

from beeflow.lambdas.dag_parsing_trigger.trigger import prepare_event


@mock.patch('time.time', return_value=1000)
def test_get_event(_obj):
    event = prepare_event()
    assert event.triggered_at == "16"
