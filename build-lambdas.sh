#!/bin/bash

echo "Building Lambda dependencies with Docker..."

lambdas=("text_extractor" "embedding_generator" "data_storer")

for lambda in "${lambdas[@]}"; do
    echo ""
    echo "Building $lambda..."
    
    cd "lambdas/$lambda"
    
    # Clean using Docker with Python to remove directories
    docker run --rm \
      --entrypoint python \
      -v "$(pwd)":/var/task \
      -w /var/task \
      public.ecr.aws/lambda/python:3.13 \
      -c "import os, shutil; [shutil.rmtree(d) for d in os.listdir('.') if os.path.isdir(d) and d not in ['__pycache__']]"
    
    # Install dependencies with pip entrypoint
    docker run --rm \
      --entrypoint pip \
      -v "$(pwd)":/var/task \
      public.ecr.aws/lambda/python:3.13 \
      install -r requirements.txt -t .
    
    if [ $? -eq 0 ]; then
        echo "✓ $lambda complete"
    else
        echo "✗ $lambda failed"
        exit 1
    fi
    
    cd ../..
done

echo ""
echo "✓ All Lambdas built successfully!"
echo "Run 'cd terraform && terraform apply' to deploy"
