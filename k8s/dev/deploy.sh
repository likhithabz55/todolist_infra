#!/bin/bash

# Usage: ./deploy.sh <namespace> <frontend_version>
# Example: ./deploy.sh blue/green/qat/uat 01

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
envsubst < deployment-template.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply service definition
envsubst < ingress-service-template.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


echo "Deployment to '$NAMESPACE' complete."
