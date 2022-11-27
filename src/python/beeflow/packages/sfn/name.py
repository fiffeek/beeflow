import hashlib

from beeflow.packages.events.task_instance_queued_event import TaskInstanceQueued


class StepFunctionsNameCreator:
    @staticmethod
    def from_ti_queued_event(event: TaskInstanceQueued) -> str:
        m = hashlib.sha256()

        m.update(bytes(event.dag_id, 'UTF-8'))
        m.update(bytes(event.task_id, 'UTF-8'))
        m.update(bytes(event.run_id, 'UTF-8'))
        m.update(bytes(event.queued_dttm, 'UTF-8'))
        m.update(bytes(str(event.map_index), 'UTF-8'))
        m.update(bytes(str(event.try_number), 'UTF-8'))

        return m.hexdigest()
