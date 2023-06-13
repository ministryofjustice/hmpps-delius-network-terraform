#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import boto3
import gzip
import io
import os

def handler(event, context):
    # Specify the details of the source S3 bucket and the file to be unzipped
    source_bucket = os.getenv("SOURCE_BUCKET")
    #prefixes = ['daily/', 'hourly/']
    prefix = 'daily/'
    
    # Specify the details of the destination S3 bucket
    destination_bucket = os.getenv("DESTINATION_BUCKET")

    # Set up S3 client
    s3 = boto3.client("s3")
    
    # List objects in the source bucket with the specified prefix
    response = s3.list_objects_v2(Bucket=source_bucket, Prefix=prefix)

    # Iterate through the objects and process each file
    for obj in response.get('Contents', []):
        object_key = obj['Key']

        # Check if the object is a gzipped file
        if object_key.endswith('.gz'):
            # Download the gzipped file from the source bucket in chunks
            response = s3.get_object(Bucket=source_bucket, Key=object_key, Range='bytes=0-')
            gz_body = response['Body']

            # Create a streaming gzip object
            gz_stream = gzip.GzipFile(fileobj=gz_body, mode='rb')

            # Unzip the contents of the gzipped file and upload in chunks
            unzipped_chunks = []
            while True:
                chunk = gz_stream.read(1024)  # Adjust the chunk size as needed
                if not chunk:
                    break
                unzipped_chunks.append(chunk)

            # Join the unzipped chunks into a single byte string
            unzipped_data = b''.join(unzipped_chunks)

            # Upload the unzipped data to the destination bucket
            destination_key = 'destination-folder/' + object_key[:-3]
            s3.put_object(Body=unzipped_data, Bucket=destination_bucket, Key=destination_key)

    return {
        "statusCode": 200,
        "body": "File unzipped and uploaded successfully. Data transfer completed."
    }

if __name__ == "__main__":
    handler(None, None)