import base64
import logging
import time
from dataclasses import dataclass
from http import HTTPStatus

import requests
from beeflow.experiments.internal.services.dags_manager.dags_manager import IDagsManager
from mypy_boto3_mwaa.client import MWAAClient


@dataclass
class MWAACLIResponse:
    stdout: str
    stderr: str
    status_code: int


class MWAADagsManager(IDagsManager):
    def __init__(self, mwaa_environment_name: str, mwaa_client: MWAAClient):
        self.mwaa_client = mwaa_client
        self.mwaa_environment_name = mwaa_environment_name

    def wait_until_dag_exists(self, dag_id: str, timeout_seconds: int = 300) -> None:
        def dag_exists() -> bool:
            payload = f"dags list-jobs -d {dag_id}"
            response = self.__execute_cli(payload)
            return self.__is_response_ok(response)

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
        payload = f"dags unpause {dag_id}"
        response = self.__execute_cli(payload)
        if not self.__is_response_ok(response):
            raise ValueError(
                f"Can't start dag {dag_id}, stdout: {response.stdout}, stderr: {response.stderr}"
            )

    def stop_dag(self, dag_id: str) -> None:
        payload = f"dags pause {dag_id}"
        response = self.__execute_cli(payload)
        if not self.__is_response_ok(response):
            raise ValueError(f"Can't stop dag {dag_id}, stdout: {response.stdout}, stderr: {response.stderr}")

    def delete_dag(self, dag_id: str) -> None:
        payload = f"dags delete -y {dag_id}"
        response = self.__execute_cli(payload)
        if not self.__is_response_ok(response):
            raise ValueError(
                f"Can't delete dag {dag_id}, stdout: {response.stdout}, stderr: {response.stderr}"
            )

    def trigger_dag(self, dag_id: str) -> None:
        payload = f"dags trigger {dag_id}"
        response = self.__execute_cli(payload)
        if not self.__is_response_ok(response):
            raise ValueError(
                f"Can't trigger dag {dag_id}, stdout: {response.stdout}, stderr: {response.stderr}"
            )

    @staticmethod
    def __is_response_ok(response: MWAACLIResponse) -> bool:
        return response.status_code == HTTPStatus.OK

    def __execute_cli(self, action: str) -> MWAACLIResponse:
        response = self.mwaa_client.create_cli_token(Name=self.mwaa_environment_name)
        hostname = f"https://{response['WebServerHostname']}/aws_mwaa/cli"
        mwaa_response = requests.post(
            hostname,
            headers={'Authorization': response["CliToken"], 'Content-Type': 'text/plain'},
            data=action,
        )
        stdout = (
            base64.b64decode(mwaa_response.json()['stdout']).decode('utf8')
            if "stdout" in mwaa_response.json()
            else ""
        )
        stderr = (
            base64.b64decode(mwaa_response.json()['stderr']).decode('utf8')
            if "stderr" in mwaa_response.json()
            else ""
        )
        return MWAACLIResponse(
            stdout=stdout,
            stderr=stderr,
            status_code=mwaa_response.status_code,
        )
