from beeflow.lambdas.batch_executor.batch_executor import get_name
from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued


def test_get_name():
    name = get_name(event=TaskInstanceQueued(dag_id="dag%%%",
                                             run_id="!@#!@#$#%%$&&%scheduled__2022-10-25T19:55:00+00:00",
                                             task_id="task2137",
                                             map_index=1,
                                             try_number=1,
                                             pool="",
                                             queue="lambda"))
    assert name == "dag-scheduled__2022-10-25T1955000000-task2137"
