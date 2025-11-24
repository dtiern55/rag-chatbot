import json


def lambda_handler(event, context):
    # TODO: Extract text from document

    body = json.dumps("Hello from text_extractor!")
    return {
        "statusCode": 200,
        "body": body,
    }
