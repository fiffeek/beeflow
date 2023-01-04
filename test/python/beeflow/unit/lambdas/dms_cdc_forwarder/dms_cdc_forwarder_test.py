import json
from base64 import b64encode
from unittest.mock import Mock

import boto3
from aws_lambda_powertools.utilities.data_classes import KinesisStreamEvent
from beeflow.lambdas.dms_cdc_forwarder.dms_cdc_forwarder import handle_records
from moto.events import mock_events

input = KinesisStreamEvent(
    data={
        "Records": [
            {
                "kinesis": {
                    "kinesisSchemaVersion": "1.0",
                    "partitionKey": "1",
                    "sequenceNumber": "49590338271490256608559692538361571095921575989136588898",
                    "data": b64encode(
                        bytes(
                            json.dumps(
                                {
                                    "data": {
                                        "task_id": "run_this_last",
                                        "dag_id": "beeflow_lambda_only",
                                        "run_id": "manual__2022-12-18T19:28:42.442556+00:00",
                                        "try_number": 0,
                                        "unixname": "airflow",
                                        "pool": "default_pool",
                                        "queue": "lambda",
                                        "priority_weight": 1,
                                        "operator": "EmptyOperator",
                                        "max_tries": 0,
                                        "executor_config": "0x80057D942E",
                                        "pool_slots": 1,
                                        "map_index": -1,
                                    },
                                    "metadata": {
                                        "timestamp": "2022-12-18T19:28:42.524922Z",
                                        "record-type": "data",
                                        "operation": "insert",
                                        "partition-key-type": "schema-table",
                                        "schema-name": "public",
                                        "table-name": "task_instance",
                                        "transaction-id": 364547,
                                    },
                                }
                            ),
                            'utf-8',
                        )
                    ),
                    "approximateArrivalTimestamp": 1545084650.987,
                },
                "eventSource": "aws:kinesis",
                "eventVersion": "1.0",
                "eventID": "shardId-000000000006:49590338271490256608559692538361571095921575989136588898",
                "eventName": "aws:kinesis:record",
                "invokeIdentityArn": "arn:aws:iam::123456789012:role/lambda-role",
                "awsRegion": "us-east-2",
                "eventSourceARN": "arn:aws:kinesis:us-east-2:123456789012:stream/lambda-stream",
            },
            {
                "kinesis": {
                    "kinesisSchemaVersion": "1.0",
                    "partitionKey": "1",
                    "sequenceNumber": "49590338271490256608559692538361571095921575989136588897",
                    "data": b64encode(
                        bytes(
                            json.dumps(
                                {
                                    "data": {"id": 2636},
                                    "metadata": {
                                        "timestamp": "2022-12-24T12:49:52.607759Z",
                                        "record-type": "data",
                                        "operation": "delete",
                                        "partition-key-type": "schema-table",
                                        "schema-name": "public",
                                        "table-name": "dag_run",
                                        "transaction-id": 372172,
                                    },
                                }
                            ),
                            'utf-8',
                        )
                    ),
                    "approximateArrivalTimestamp": 1545084650.988,
                },
                "eventSource": "aws:kinesis",
                "eventVersion": "1.0",
                "eventID": "shardId-000000000006:49590338271490256608559692538361571095921575989136588897",
                "eventName": "aws:kinesis:record",
                "invokeIdentityArn": "arn:aws:iam::123456789012:role/lambda-role",
                "awsRegion": "us-east-2",
                "eventSourceARN": "arn:aws:kinesis:us-east-2:123456789012:stream/lambda-stream",
            },
            {
                "kinesis": {
                    "kinesisSchemaVersion": "1.0",
                    "partitionKey": "1",
                    "sequenceNumber": "49590338271490256608559692540925702759324208523137515618",
                    "data": b64encode(
                        bytes(
                            json.dumps(
                                {
                                    "data": {
                                        "id": 2583,
                                        "dag_id": "beeflow_lambda_only",
                                        "execution_date": "2022-12-18T19:28:42.442556Z",
                                        "state": "queued",
                                        "run_id": "manual__2022-12-18T19:28:42.442556+00:00",
                                        "external_trigger": "t",
                                        "conf": "0x80057D942E",
                                        "run_type": "manual",
                                        "dag_hash": "47df48931be256c11cced337c1d5d9d8",
                                        "queued_at": "2022-12-18T19:28:42.473943Z",
                                        "data_interval_start": "2022-12-18T19:20:00Z",
                                        "data_interval_end": "2022-12-18T19:25:00Z",
                                        "log_template_id": 1,
                                    },
                                    "metadata": {
                                        "timestamp": "2022-12-18T19:28:42.512304Z",
                                        "record-type": "data",
                                        "operation": "insert",
                                        "partition-key-type": "schema-table",
                                        "schema-name": "public",
                                        "table-name": "dag_run",
                                        "transaction-id": 364547,
                                    },
                                }
                            ),
                            'utf-8',
                        )
                    ),
                    "approximateArrivalTimestamp": 1545084711.166,
                },
                "eventSource": "aws:kinesis",
                "eventVersion": "1.0",
                "eventID": "shardId-000000000006:49590338271490256608559692540925702759324208523137515618",
                "eventName": "aws:kinesis:record",
                "invokeIdentityArn": "arn:aws:iam::123456789012:role/lambda-role",
                "awsRegion": "us-east-2",
                "eventSourceARN": "arn:aws:kinesis:us-east-2:123456789012:stream/lambda-stream",
            },
        ]
    }
)


@mock_events
def test_handle_kinesis_events():
    output = handle_records(event=input, events_client=boto3.client("events"), busname="bus")
    assert output["batchItemFailures"] == []


def test_handle_kinesis_events_partial_failure():
    boto3_events_client = Mock()
    boto3_events_client.put_events = Mock(
        return_value={
            "Entries": [
                {
                    "ErrorCode": 400,
                },
                {
                    "EventId": "123",
                },
            ]
        }
    )
    output = handle_records(event=input, events_client=boto3_events_client, busname="bus")
    assert output["batchItemFailures"] == [
        {"itemIdentifier": "shardId-000000000006:49590338271490256608559692538361571095921575989136588898"}
    ]
