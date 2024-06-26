import json
import logging
import time
from http import HTTPStatus

from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from mypy_boto3_lambda import LambdaClient
from mypy_boto3_lambda.type_defs import InvocationResponseTypeDef


class BeeflowDagsManager(IDagsManager):
    def __init__(self, lambda_client: LambdaClient, function_name: str):
        self.lambda_client = lambda_client
        self.function_name = function_name

    def scale_default_pool(self, pool_size: int) -> None:
        payload = json.dumps({"args": ["pools", "set", "default_pool", f"{pool_size}", "default"]})
        response = self.__invoke_cli(payload)

        if not self.__invocation_ok(response):
            raise Exception(f"Cannot scale default_pool to {pool_size}")

    def wait_until_dag_exists(self, dag_id: str, timeout_seconds: int = 300) -> None:
        def dag_exists() -> bool:
            payload = json.dumps({"args": ["dags", "list-jobs", "-d", dag_id]})
            response = self.__invoke_cli(payload)
            return self.__invocation_ok(response)

        t_end = time.time() + timeout_seconds
        while time.time() < t_end:
            if dag_exists():
                logging.info(f"DAG {dag_id} already exists")
                break
            logging.info(f"DAG {dag_id} does not exist yet")
            time.sleep(15)

        if not dag_exists():
            raise Exception(f"DAG {dag_id} does not exist and {timeout_seconds} elapsed")

    def start_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "unpause", dag_id]})
        response = self.__invoke_cli(payload)

        if not self.__invocation_ok(response):
            raise Exception(f"Cannot mark {dag_id} as active")

    def delete_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "delete", "-y", dag_id]})
        response = self.__invoke_cli(payload)

        if not self.__invocation_ok(response):
            raise Exception(f"Cannot delete {dag_id}: {response}")

    def stop_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "pause", dag_id]})
        response = self.__invoke_cli(payload)

        if not self.__invocation_ok(response):
            raise Exception(f"Cannot mark {dag_id} as active")

    def trigger_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "trigger", dag_id]})
        response = self.__invoke_cli(payload)

        if not self.__invocation_ok(response):
            raise Exception(f"Cannot export experiment results: {response}")

    def __invoke_cli(self, payload: str) -> InvocationResponseTypeDef:
        return self.lambda_client.invoke(
            FunctionName=self.function_name,
            InvocationType="RequestResponse",
            LogType="None",
            Payload=payload,
        )

    @staticmethod
    def __invocation_ok(response: InvocationResponseTypeDef) -> bool:
        return "FunctionError" not in response and response["StatusCode"] == HTTPStatus.OK
