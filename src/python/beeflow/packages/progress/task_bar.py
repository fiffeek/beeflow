import time
from typing import Optional

from rich.progress import Progress, TaskID


def sleep(
    seconds: int,
    progress: Progress,
    task_id: Optional[TaskID] = None,
    task_description: Optional[str] = None,
    hide_after_done: bool = False,
) -> None:
    should_delete_task = False
    if task_id is None:
        task_id = progress.add_task(
            task_description or "",
            total=seconds,
            start=True,
        )
        should_delete_task = True
    for _ in range(seconds):
        time.sleep(1)
        progress.update(task_id, advance=1)
    if hide_after_done or should_delete_task:
        progress.stop_task(task_id)
        progress.update(task_id, visible=False)
    if should_delete_task:
        progress.remove_task(task_id)
