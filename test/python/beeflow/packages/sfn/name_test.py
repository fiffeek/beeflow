from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued
from beeflow.packages.sfn.name import StepFunctionsNameCreator


def test_crate_sanitized_name():
    event = TaskInstanceQueued(
        dag_id="dag%%%",
        run_id="!@#!@#$#%%$&&%scheduled__2022-10-25T19:55:00+00:00",
        task_id="task2137",
        map_index=1,
        try_number=1,
        pool="",
        queue="lambda",
        queued_dttm="132",
    )
    assert StepFunctionsNameCreator.from_ti_queued_event(event) \
           == "d054340c095e27385ad378752434750b34e706359b8578e2f00bf4e8d99b9e4c"
