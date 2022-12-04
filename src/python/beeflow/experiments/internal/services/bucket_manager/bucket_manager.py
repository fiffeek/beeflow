import abc
import os
from os import listdir
from os.path import isfile, join

from mypy_boto3_s3.service_resource import Bucket


class IBucketManager(abc.ABC):
    @abc.abstractmethod
    def clear_dags(self) -> None:
        pass

    @abc.abstractmethod
    def publish_dags(self, dags_path: str) -> [str]:
        pass


class BucketManager(IBucketManager):
    def __init__(self, bucket: Bucket):
        self.bucket = bucket

    def clear_dags(self) -> None:
        self.bucket.objects.all().delete()

    def publish_dags(self, dags_path: str) -> [str]:
        if not os.path.isdir(dags_path):
            raise ValueError(f"Dag's path {dags_path} is not a valid directory")

        files = [f for f in listdir(dags_path) if isfile(join(dags_path, f)) and f not in ["BUILD"]]
        for file in files:
            self.bucket.upload_file(
                Filename=os.path.join(dags_path, file),
                Key=file,
            )

        return files
