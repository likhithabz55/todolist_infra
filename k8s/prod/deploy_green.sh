#!/bin/bash

aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

#set -euo pipefail

# Validate input
#if [ "$#" -ne 2 ]; then
#  echo "Usage: $0 <namespace> <subdomain>"
#  echo "Example: $0 prod prod-green"
#  exit 1
#fi

NAMESPACE="prod"
SUBDOMAIN="prod-green"


###EXTRACT LATEST TAG

REPO_NAME="blue_green_ecr/frontend"
AWS_REGION="us-east-1"

FRONTEND_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

echo "Latest image tag: $FRONTEND_VERSION"

VERSION_COLOUR="${FRONTEND_VERSION//./-}"
echo "$VERSION_COLOUR"

export FRONTEND_VERSION
export NAMESPACE VERSION_COLOUR
export SUBDOMAIN

echo "Deploying green version: $FRONTEND_VERSION to namespace: $NAMESPACE..."

# Apply frontend deployment with substituted environment variables
envsubst < frontend/deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply service definition
envsubst < ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


