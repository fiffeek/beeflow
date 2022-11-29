import os
import random
import string

import boto3
import pytest
from moto import mock_s3

pytest.aws_region = 'us-east-1'


@pytest.fixture(scope='function')
def aws_credentials():
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_ID'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'


@pytest.fixture
def s3_resource(aws_credentials):
    with mock_s3():
        s3 = boto3.resource('s3')
        yield s3


@pytest.fixture
def s3_client(aws_credentials):
    with mock_s3():
        s3 = boto3.client('s3', region_name=pytest.aws_region)
        yield s3


@pytest.fixture
def s3_bucket(s3_resource, s3_client):
    my_bucket = ''.join(random.choices(string.ascii_letters + string.digits, k=16))
    s3_client.create_bucket(Bucket=my_bucket)
    return s3_resource.Bucket(my_bucket)
