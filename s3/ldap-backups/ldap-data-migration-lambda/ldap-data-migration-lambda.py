#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import boto3
import gzip
import io
import os
import logging

log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logger = logging.getLogger()
logging.basicConfig(level=log_level)

def handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info("DESTINATION_BUCKET: " + os.getenv("DESTINATION_BUCKET") )
    logger.info("DESTINATION_FOLDER: " + os.getenv("DESTINATION_FOLDER"))
    logger.info("SOURCE_BUCKET: " + os.getenv("SOURCE_BUCKET"))
    logger.info("SOURCE_PREFIX: " + os.getenv("SOURCE_PREFIX"))
    logger.info("LOG_LEVEL: " + os.getenv("LOG_LEVEL"))

    # Specify the details of the source S3 bucket and the file to be unzipped
    source_bucket = os.getenv("SOURCE_BUCKET")
    prefix = os.getenv("SOURCE_PREFIX")

    # Specify the details of the destination S3 bucket
    destination_bucket = os.getenv("DESTINATION_BUCKET")
    chunk_size = int(os.getenv("CHUNK_SIZE", 1024 * 1024))

    # Set up S3 client
    s3 = boto3.client("s3")

    # List objects in the source bucket with the specified prefix
    response = s3.list_objects_v2(Bucket=source_bucket, Prefix=prefix)
    logger.debug(f"Response: {response}")

    logger.info(f"Looping over objects in the source bucket {source_bucket}/{prefix}")
    
    # Iterate through the objects and process each file
    for obj in response.get("Contents", []):
        
        object_key = obj["Key"]

        logger.info(f"Processing object {object_key}")

        # Check if the object is a gzipped file
        if object_key.endswith(".gz"):
            logger.info(f"Object {object_key} is a gzipped file. Downloading and unzipping.")

            # Download the gzipped file from the source bucket in chunks
            try:
              response = s3.get_object(Bucket=source_bucket, Key=object_key, Range="bytes=0-")
            except Exception as e:
                logger.error(f"Error downloading file {object_key} from bucket {source_bucket}: {e}")
                raise e
            
            gz_body = response["Body"]

            # Create a streaming gzip object
            gz_stream = gzip.GzipFile(fileobj=gz_body, mode="rb")

            # Unzip the contents of the gzipped file and upload in chunks
            unzipped_chunks = []
            while chunk := gz_stream.read(chunk_size):
                unzipped_chunks.append(chunk)

            # Join the unzipped chunks into a single byte string
            unzipped_data = b"".join(unzipped_chunks)

            # Extract object name and remove file ext
            object_name = os.path.basename(object_key[:-3])
            # Upload the unzipped data to the destination bucket
            destination_key = os.getenv("DESTINATION_FOLDER") + object_name
            logger.info(f"Uploading unzipped data to {destination_bucket}/{destination_key}")

            # Create a file like object from the unzipped data
            file_object = io.BytesIO(unzipped_data)
            try:
                s3.upload_fileobj(file_object, destination_bucket, destination_key)
            except Exception as e:
                logger.error(f"Error uploading file {destination_key} to bucket {destination_bucket}: {e}")
                raise e

    return {"statusCode": 200, "body": "File unzipped and uploaded successfully. Data transfer completed."}


if __name__ == "__main__":
    handler(None, None)
