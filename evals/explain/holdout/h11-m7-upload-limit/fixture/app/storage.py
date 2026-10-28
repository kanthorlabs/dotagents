import boto3

from app.settings import BUCKET

_s3 = boto3.client("s3")


def put(key, stream, content_type):
    _s3.upload_fileobj(stream, BUCKET, key, ExtraArgs={"ContentType": content_type})


def presign_post(key, max_bytes, expires_seconds):
    return _s3.generate_presigned_post(
        BUCKET,
        key,
        Conditions=[["content-length-range", 1, max_bytes]],
        ExpiresIn=expires_seconds,
    )
