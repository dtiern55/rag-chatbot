import json
import boto3

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

    # TODO: Get the bucket and key from the event
    # TODO: Download the file from S3
    # TODO: Determine file type and extract text accordingly (PDF, Word, etc.)
    # TODO: Generate unique document ID (e.g., using UUID)
    # TODO: Return the extracted text and document ID in the response

    body = json.dumps("Hello from text_extractor!")
    return {
        "statusCode": 200,
        "body": body,
    }
