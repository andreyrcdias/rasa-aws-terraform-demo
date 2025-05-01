#!/bin/bash
set -e

if [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "ERROR: AWS_REGION and AWS_ACCOUNT_ID must be set."
  exit 1
fi

REPOSITORY_NAMES=(
  "chat-actions"
  "chat-api"
)
DOCKERFILE_PATHS=(
  "./actions.Dockerfile"
  "./bot.Dockerfile"
)

# Authenticate docker to ECR
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Build and push each Docker image
for i in "${!REPOSITORY_NAMES[@]}"; do
  REPO=${REPOSITORY_NAMES[$i]}
  DOCKERFILE_PATH=${DOCKERFILE_PATHS[$i]}

  echo "🧱  Building $REPO..."
  docker build --no-cache -f "$DOCKERFILE_PATH" -t "$REPO" ..

  echo "📧  Tagging $REPO..."
  docker tag "$REPO:latest" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO:latest"

  echo "🛫  Pushing $REPO...\n"
  docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO:latest"
done

