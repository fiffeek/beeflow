from beeflow.experiments.dags.bucket_manager import BucketManager


def test_clear_objects(s3_bucket):
    bm = BucketManager(s3_bucket)
    s3_bucket.put_object(Key="some_key", Body=b"samoyed")

    bm.clear_dags()

    objs = [obj for obj in s3_bucket.objects.all()]
    assert objs == []


def test_move_file_with_content(s3_bucket, tmp_path):
    bm = BucketManager(s3_bucket)
    f1 = tmp_path / "experiment_dir/dag_file.py"
    f1.parent.mkdir()
    f1.touch()
    f1.write_text("content")

    bm.publish_experiment(str(f1.parent.absolute()))

    objs = [obj for obj in s3_bucket.objects.all()]
    assert len(objs) == 1
    dag_file = objs[0]
    assert dag_file.key == "dag_file.py"
    assert dag_file.get()['Body'].read() == b"content"


def test_move_multiple_files(s3_bucket, tmp_path):
    bm = BucketManager(s3_bucket)
    f1 = tmp_path / "experiment_dir/dag_file.py"
    f1.parent.mkdir()
    f1.touch()
    f2 = tmp_path / "experiment_dir/dag_file2.py"
    f2.touch()

    bm.publish_experiment(str(f1.parent.absolute()))

    objs = [obj.key for obj in s3_bucket.objects.all()]
    assert sorted(objs) == sorted(["dag_file.py", "dag_file2.py"])
