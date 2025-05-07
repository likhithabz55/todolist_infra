#!/bin/bash

# Usage: ./promote.sh <from-namespace> <to-namespace>
# Example: ./promote.sh blue green

FROM_VERSION=$1
TO_VERSION=$2

NAMESPACE="prod"

export FROM_VERSION TO_VERSION
export NAMESPACE


if [[ -z "$FROM_VERSION" || -z "$TO_VERSION" ]]; then
  echo "Usage: $0 <from-namespace> <to-namespace>"
  exit 1
fi

REPO_NAME="blue_green_ecr/frontend"
AWS_REGION="us-east-1"

FRONTEND_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

echo "Latest image tag: $FRONTEND_VERSION"

echo "Promoting from env '$FROM_VERSION' to '$TO_VERSION'..."

# Remove the current ingress from the source namespace
kubectl delete ingress proxy-prod-ingress --namespace $NAMESPACE

VERSION_COLOUR="${FRONTEND_VERSION//./-}"
echo "$VERSION_COLOUR"
export VERSION_COLOUR

# Apply production service in the target namespace
envsubst < prod_ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

echo "Promotion complete."
