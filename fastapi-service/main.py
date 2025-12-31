from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import lancedb
import os
import boto3
from decimal import Decimal

app = FastAPI(title="RAG Chatbot Query API")

# Initialize LanceDB
db_path = os.environ.get("LANCEDB_PATH", "/data/lancedb")
db = lancedb.connect(db_path)

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table_name = os.environ.get('DYNAMODB_TABLE_NAME', 'rag-chatbot-metadata-dev')
table = dynamodb.Table(table_name)

# Bedrock client for generating query embeddings
bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')


class QueryRequest(BaseModel):
    query: str
    top_k: int = 5


class QueryResponse(BaseModel):
    results: List[dict]


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}


@app.post("/query", response_model=QueryResponse)
async def query_documents(request: QueryRequest):
    """
    Query documents using semantic search
    
    1. Generate embedding for the query
    2. Search LanceDB for similar vectors
    3. Retrieve full chunk text from DynamoDB
    4. Return results
    """
    
    # Generate embedding for the query
    query_embedding = generate_embedding(request.query)
    
    # Search LanceDB for similar vectors
    # Note: We'll implement this after we have data in LanceDB
    # For now, return a placeholder
    
    return QueryResponse(results=[
        {"message": "LanceDB search not yet implemented - need to migrate embeddings first"}
    ])


@app.get("/tables")
async def list_tables():
    """List available LanceDB tables"""
    tables = db.table_names()
    return {"tables": tables}


@app.get("/stats")
async def get_stats():
    """Get statistics about stored documents"""
    
    # Count chunks in DynamoDB
    response = table.scan(Select='COUNT')
    chunk_count = response['Count']
    
    # LanceDB table info
    lance_tables = db.table_names()
    
    return {
        "dynamodb_chunks": chunk_count,
        "lancedb_tables": lance_tables
    }


def generate_embedding(text: str) -> List[float]:
    """Generate embedding for text using Bedrock Titan"""
    import json
    
    request_body = json.dumps({"inputText": text})
    
    response = bedrock.invoke_model(
        modelId="amazon.titan-embed-text-v1",
        contentType="application/json",
        accept="application/json",
        body=request_body
    )
    
    response_body = json.loads(response['body'].read())
    return response_body['embedding']


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)