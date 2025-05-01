#!/bin/bash
set -e

if [ -z "$MODELS_BUCKET" ]; then
  echo "ERROR: MODELS_BUCKET must be set."
  exit 1
fi

MODEL_NAME="models.tar.gz"
FILE_PATH="models/$MODEL_NAME"

if [[ ! -f "$FILE_PATH" ]]; then
  echo "File $FILE_PATH does not exist."
  exit 1
fi

FILE_SIZE=$(ls -lh "$FILE_PATH" | awk '{print $5}')
echo "Size of $MODEL_NAME: $FILE_SIZE"

# Upload the trained model to the root of the S3 bucket
aws s3 cp "$FILE_PATH" "s3://$MODELS_BUCKET/$MODEL_NAME"

if [[ $? -eq 0 ]]; then
  echo "File uploaded successfully to s3://$MODELS_BUCKET/$MODEL_NAME"
else
  echo "Failed to upload the file."
  exit 1
fi
