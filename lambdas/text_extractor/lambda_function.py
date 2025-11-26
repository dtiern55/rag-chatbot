from io import BytesIO
import os
from PyPDF2 import PdfReader
import boto3
import uuid
from docx import Document

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

    # Step 1: Get file info from event
    bucket = event.get("bucket")
    key = event.get("key")

    print(f"Processing file: s3://{bucket}/{key}")

    # Step 2: Download file from S3
    response = s3_client.get_object(Bucket=bucket, Key=key)
    file_content = response["Body"].read()

    # Step 3: Determine file type and extract text
    filename = os.path.basename(key)
    print(
        f"Extracting text from file: {filename} " f"(filename = os.path.basename(key))"
    )
    file_extension = os.path.splitext(filename)[1].lower()
    print(
        f"File extension: {file_extension} "
        f"(file_extension = os.path.splitext(filename)[1].lower())"
    )

    if file_extension == ".pdf":
        text = "Extracted text from PDF"
    elif file_extension in [".docx", ".doc"]:
        text = "Extracted text from Word document"
    elif file_extension == ".txt":
        text = file_content.decode("utf-8")
    else:
        raise ValueError(f"Unsupported file type: {file_extension}")

    # Step 4: Generate unique document ID
    document_id = str(uuid.uuid4())

    # Step 5: Return extracted data
    return {
        "document_id": document_id,
        "filename": filename,
        "text": text,
        "file_type": file_extension,
        "bucket": bucket,
        "key": key,
    }


def extract_text_from_pdf(file_content):
    """Extract text from a PDF"""
    pdf_file = BytesIO(file_content)
    reader = PdfReader(pdf_file)

    text = ""
    for page in reader.pages:
        text += page.extract_text() + "\n"

    return text.strip()


def extract_text_from_word(file_content):
    """Extract text from a Word document"""
    word_file = BytesIO(file_content)
    document = Document(word_file)

    text = ""
    for paragraph in document.paragraphs:
        text += paragraph.text + "\n"

    return text.strip()
