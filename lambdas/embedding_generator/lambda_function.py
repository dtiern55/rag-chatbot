import json


def lambda_handler(event, context):
    # TODO: Extract text from document

    body = json.dumps("Hello from embedding_generator!")
    return {
        "statusCode": 200,
        "body": body,
    }
