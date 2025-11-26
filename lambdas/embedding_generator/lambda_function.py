import json
import boto3

bedrock_runtime = boto3.client("bedrock-runtime", region_name="us-east-1")

# Bedrock model ID for Titan Embeddings
EMBEDDING_MODEL_ID = "amazon.titan-embed-text-v1"


def lambda_handler(event, context):
    """
    Generate embeddings for text chunks

    Expected event format:
    {
        "document_id": "uuid-123",
        "filename": "file.pdf",
        "file_type": ".pdf",
        "chunks": [
            {
                "chunk_index": 0,
                "chunk_text": "Text of chunk 0...",
                "word_count": 100
            },
        ],
        "total_chunks": 10,
        "metadata": {
            "original_length": 5000,
            "bucket": "...",
            "key": "..."
        }
        ],
    }
    """

    chunks = event.get("chunks", [])
    document_id = event["document_id"]
    print(f"Generating embeddings for {len(chunks)} chunks from document {document_id}")
    enriched_chunks = []

    # Step 1: Loop through chunks
    for chunk in chunks:
        chunk_index = chunk["chunk_index"]
        chunk_text = chunk["chunk_text"]

        print(f"Processing chunk {chunk_index}")

        # Step 2: Call Bedrock Titan Embeddings API to generate embeddings for each chunk
        embedding = generate_embedding(chunk_text)
        print(f"Generated embedding for chunk {chunk.get('chunk_index')}")

        # Step 3: Attach embedding vector to each chunk
        enriched_chunk = {
            "chunk_index": chunk_index,
            "chunk_text": chunk_text,
            "word_count": chunk["word_count"],
            "embedding": embedding,
        }
        enriched_chunks.append(enriched_chunk)
        print(f"Enriched chunk {chunk_index} with embedding")

    # Step 4: Return chunks with embeddings
    return {
        "document_id": document_id,
        "filename": event["filename"],
        "file_type": event["file_type"],
        "chunks": enriched_chunks,
        "total_chunks": len(enriched_chunks),
        "metadata": event.get("metadata", {}),
    }


def generate_embedding(text):
    """
    Call Bedrock Titan to generate embedding vector for text
    """

    request_body = json.dumps({"inputText": text})
    print(f"DEBUGGING: Request body for embedding generation: {request_body}")

    response = bedrock_runtime.invoke_model(
        modelId=EMBEDDING_MODEL_ID,
        contentType="application/json",
        accept="application/json",
        body=request_body,
    )
    print(f"DEBUGGING: Response from embedding generation: {response}")

    response_body = json.loads(response["body"].read())
    print(f"DEBUGGING: Response body for embedding generation: {response_body}")
    embedding = response_body["embedding"]

    return embedding
