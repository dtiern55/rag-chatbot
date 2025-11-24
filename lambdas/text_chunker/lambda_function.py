import json


def lambda_handler(event, context):
    # TODO: Extract text from document

    body = json.dumps("Hello from text_chunker!")
    return {
        "statusCode": 200,
        "body": body,
    }
