import boto3

_s3 = boto3.client("s3")
BUCKET = "lantern-thumbs"


def put_thumbnail(key, image_bytes):
    _s3.put_object(Bucket=BUCKET, Key=key, Body=image_bytes, ContentType="image/webp")
