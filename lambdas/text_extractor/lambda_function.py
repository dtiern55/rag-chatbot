import json
import os
import boto3
import uuid

s3_client = boto3.client("s3")


def lambda_handler(event, context):
    """
    Extract text from a document in S3

    Expected event format:
    {
        "bucket": "rag-chatbot-${environment}-input",
        "key": "documents/my-file.pdf"
    }
    """

    bucket = event.get("bucket")
    key = event.get("key")

    print(f"Processing file: s3://{bucket}/{key}")

    response = s3_client.get_object(Bucket=bucket, Key=key)
    file_content = response["Body"].read()

    filename = os.path.basename(key)
    print(f"Extracting text from file: {filename} (filename = os.path.basename(key))")
    file_extension = os.path.splitext(filename)[1].lower()
    print(
        f"File extension: {file_extension} (file_extension = os.path.splitext(filename)[1].lower())"
    )

    if file_extension == ".pdf":
        text = "Extracted text from PDF"  # TODO: Implement PDF text extraction
    elif file_extension in [".docx", ".doc"]:
        text = (
            "Extracted text from Word document"  # TODO: Implement Word text extraction
        )
    elif file_extension == ".txt":
        text = file_content.decode("utf-8")
    else:
        raise ValueError(f"Unsupported file type: {file_extension}")

    document_id = str(uuid.uuid4())
    # TODO: Return the extracted text and document ID in the response

    body = json.dumps("Hello from text_extractor!")
    return {
        "statusCode": 200,
        "body": body,
    }
