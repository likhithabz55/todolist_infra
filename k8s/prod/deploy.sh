#!/bin/bash

# Usage: ./deploy_blue.sh <namespace> <frontend_version>
# Example: ./deploy_blue.sh blue/green/qat/uat 01

aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

set -euo pipefail

# Validate input
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <namespace> <frontend_version>"
  echo "Example: $0 blue 01"
  exit 1
fi

NAMESPACE="$1"
FRONTEND_VERSION="$2"

export FRONTEND_VERSION NAMESPACE
export NAMESPACE

echo "Deploying frontend version: $FRONTEND_VERSION to namespace: $NAMESPACE..."

# Apply deployment with substituted environment variables
envsubst < deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply service definition
envsubst < ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


echo "Deployment to '$NAMESPACE' complete."