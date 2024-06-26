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
    def delete_dag(self, dag_id: str) -> None:
        pass

    @abc.abstractmethod
    def trigger_dag(self, dag_id: str) -> None:
        pass

    @abc.abstractmethod
    def scale_default_pool(self, pool_size: int) -> None:
        pass
