import boto3
import os
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE_NAME")
table = dynamodb.Table(table_name)


def lambda_handler(event, context):
    """
    Store chunk metadata and embeddings in DynamoDB

    Expected event format:
    {
        "document_id": "uuid-123",
        "filename": "file.pdf",
        "chunks": [
            {
                "chunk_index": 0,
                "text": "...",
                "word_count": 500,
                "embedding": [...]
            },
            ...
        ],
        "metadata": {...}
    }
    """

    document_id = event["document_id"]
    filename = event["filename"]
    chunks = event.get("chunks", [])
    metadata = event.get("metadata", {})

    message = (
        f"Storing {len(chunks)} chunks for document {document_id} "
        f"in DynamoDB table {table_name}"
    )
    print(message)

    # Store each chunk in DynamoDB
    stored_count = 0
    for chunk in chunks:
        try:
            store_chunk(document_id, filename, chunk, metadata)
            stored_count += 1
            print(f"Stored chunk {chunk['chunk_index']}")
        except Exception as e:
            print(f"Error storing chunk {chunk['chunk_index']}: {str(e)}")
            raise  # Re-raise to fail the Lambda

    print(f"Successfully stored {stored_count} chunks")

    # Return success
    return {
        "statusCode": 200,
        "message": f"Stored {stored_count} chunks for document {document_id}",
        "document_id": document_id,
        "chunks_stored": stored_count,
    }


def store_chunk(document_id, filename, chunk, metadata):
    """
    Store a single chunk in DynamoDB
    """

    chunk_index = chunk["chunk_index"]

    # Generate unique chunk_id for GSI lookups
    chunk_id = f"{document_id}-chunk-{chunk_index}"

    # Prepare item for DynamoDB
    item = {
        # Primary key
        "document_id": document_id,
        "chunk_index": chunk_index,
        # Unique identifier (for GSI)
        "chunk_id": chunk_id,
        # Content
        "text": chunk["chunk_text"],
        "word_count": chunk["word_count"],
        # Embedding
        # "embedding": chunk["embedding"], # Comment out - will store in LanceDB once set up
        # Document metadata
        "filename": filename,
        "file_type": metadata.get("file_type", ""),
        # Timestamps
        "created_at": datetime.utcnow().isoformat(),
        # Original S3 location
        "source_bucket": metadata.get("bucket", ""),
        "source_key": metadata.get("key", ""),
    }

    # Write to DynamoDB
    table.put_item(Item=item)
