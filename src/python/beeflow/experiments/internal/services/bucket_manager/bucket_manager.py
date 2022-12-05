import abc
import os
from os import listdir
from os.path import isfile, join
from typing import List, Optional

from mypy_boto3_s3.service_resource import Bucket


class IBucketManager(abc.ABC):
    @abc.abstractmethod
    def clear_dags(self) -> None:
        pass

    @abc.abstractmethod
    def publish_dags(self, dags_path: str) -> List[str]:
        pass


class BucketManager(IBucketManager):
    def __init__(self, bucket: Bucket, s3_dags_path: Optional[str] = None):
        self.bucket = bucket
        self.s3_dags_path = s3_dags_path

    def clear_dags(self) -> None:
        if self.s3_dags_path is None:
            self.bucket.objects.all().delete()
            return
        self.bucket.objects.filter(Prefix=f"{self.s3_dags_path}").delete()

    def publish_dags(self, dags_path: str) -> List[str]:
        if not os.path.isdir(dags_path):
            raise ValueError(f"Dag's path {dags_path} is not a valid directory")

        files = [f for f in listdir(dags_path) if isfile(join(dags_path, f)) and f not in ["BUILD"]]
        for file in files:
            s3_key = f"{self.s3_dags_path}/{file}" if self.s3_dags_path is not None else file
            self.bucket.upload_file(
                Filename=os.path.join(dags_path, file),
                Key=s3_key,
            )

        return files
