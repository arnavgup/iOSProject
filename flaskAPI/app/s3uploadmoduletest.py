import os
import boto3
S3_BUCKET = "gyao.iosproject.faceimages"
S3_KEY = os.environ.get("S3_ACCESS_KEY")
S3_SECRET = os.environ.get("S3_SECRET_ACCESS_KEY")
s3 = boto3.client('s3')
filename = "imagetest/testinner.jpg"
bucket_name = S3_BUCKET
s3.upload_file(filename, bucket_name, filename)
