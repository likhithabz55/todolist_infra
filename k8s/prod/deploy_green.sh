#!/bin/bash

# Usage: ./deploy_blue.sh <namespace> <frontend_version>
# Example: ./deploy_blue.sh blue/green/qat/uat 01

aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

NAMESPACE="prod-green"

###EXTRACT LATEST TAG

REPO_NAME="blue_green_ecr/frontend"
AWS_REGION="us-east-1"

FRONTEND_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

echo "Latest frontend version: $FRONTEND_VERSION"

export FRONTEND_VERSION
export NAMESPACE

echo "Deploying frontend version: $FRONTEND_VERSION to namespace: $NAMESPACE..."

# Apply deployment with substituted environment variables
envsubst < deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply service definition
envsubst < ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


echo "Deployment to '$NAMESPACE' complete."