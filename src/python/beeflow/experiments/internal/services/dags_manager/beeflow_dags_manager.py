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

    def wait_until_dag_exists(self, dag_id: str, timeout_seconds: int = 300) -> None:
        def dag_exists() -> bool:
            payload = json.dumps({"args": ["dags", "list-jobs", "-d", dag_id]})
            response = self.__invoke_cli(payload)
            return response["StatusCode"] == HTTPStatus.OK

        t_end = time.time() + timeout_seconds
        while time.time() < t_end:
            if dag_exists():
                break
            logging.info(f"DAG {dag_id} does not exist yet")
            time.sleep(15)

        if not dag_exists():
            raise Exception(f"DAG {dag_id} does not exist and {timeout_seconds} elapsed")

    def start_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "unpause", dag_id]})
        response = self.__invoke_cli(payload)

        if response["StatusCode"] != HTTPStatus.OK:
            raise Exception(f"Cannot mark {dag_id} as active")

    def stop_dag(self, dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "pause", dag_id]})
        response = self.__invoke_cli(payload)

        if response["StatusCode"] != HTTPStatus.OK:
            raise Exception(f"Cannot mark {dag_id} as active")

    def export_metrics(self, export_dag_id: str) -> None:
        payload = json.dumps({"args": ["dags", "test", "-c", "{}", export_dag_id]})
        response = self.__invoke_cli(payload)

        if response["StatusCode"] != HTTPStatus.OK:
            raise Exception(f"Cannot export experiment results")

    def __invoke_cli(self, payload: str) -> InvocationResponseTypeDef:
        return self.lambda_client.invoke(
            FunctionName=self.function_name,
            InvocationType="RequestResponse",
            LogType="None",
            Payload=payload,
        )
