import abc


class IDagsManager(abc.ABC):
    @abc.abstractmethod
    def wait_until_dag_exists(self, dag_id: str, timeout_seconds: int) -> None:
        pass

    @abc.abstractmethod
    def start_dag(self, dag_id: str) -> None:
        pass

    @abc.abstractmethod
    def stop_dag(self, dag_id: str) -> None:
        pass

    @abc.abstractmethod
    def export_metrics(self, export_dag_id: str) -> None:
        pass
