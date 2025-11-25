CHUNK_SIZE = 500  # Number of characters per chunk
OVERLAP_SIZE = 50  # Number of overlapping characters between chunks


def lambda_handler(event, context):
    """
    Split document text into overlapping chunks

    Expected event format:
    {
        "document_id": "uuid-123",
        "filename": "file.pdf",
        "text": "Long document text...",
        "file_type": ".pdf",
        "bucket": "...",
        "key": "..."
    }
    """

    document_id = event.get("document_id")
    filename = event.get("filename")
    text = event.get("text")

    print(f"Chunking text for document: {filename} (document_id = {document_id})")
    print(f"Total text length: {len(text)} characters")

    chunks = chunk_text(text, CHUNK_SIZE, OVERLAP_SIZE)
    print(f"Generated {len(chunks)} chunks")

    formatted_chunks = []
    for i, chunk in enumerate(chunks):
        formatted_chunks.append_idx(
            {
                "chunk_index": i,
                "chunk_text": chunk,
                "word_count": len(chunk.split()),
            }
        )

    return {
        "document_id": document_id,
        "filename": filename,
        "file_type": event.get("file_type"),
        "chunks": formatted_chunks,
        "total_chunks": len(formatted_chunks),
        "metadata": {
            "original_length": len(text),
            "bucket": event.get("bucket"),
            "key": event.get("key"),
        },
    }


def chunk_text(text, chunk_size=500, overlap_size=50):
    """
    Split text into overlapping chunks.
    """
    words = text.split()

    if len(words) < chunk_size:
        return [text]

    chunks = []
    start_idx = 0

    while start_idx < len(words):
        # Get chunk_size words starting from start_idx
        end_idx = start_idx + chunk_size
        chunk_words = words[start_idx:end_idx]

        # Join words back into text
        chunk_text = " ".join(chunk_words)
        chunks.append(chunk_text)

        # Move start index forward by (chunk_size - overlap)
        # This creates the overlap
        start_idx += chunk_size - overlap_size

        # Stop if we've processed all words
        if end_idx >= len(words):
            break

    return chunks
