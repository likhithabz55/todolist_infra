#!/bin/bash

# Usage: ./deploy_blue.sh <namespace> <frontend_version>
# Example: ./deploy_blue.sh blue/green/qat/uat 01

aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

set -euo pipefail

# Validate input
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <namespace> <other_service_versions> <frontend_version> <subdomain>"
  echo "Example: $0 blue 1.2.0 1.2.1 prod-blue"
  exit 1
fi

NAMESPACE="$1"
CURRENT_VERSION="$2"
FRONTEND_VERSION="$3"
SUBDOMAIN="$4"

export FRONTEND_VERSION CURRENT_VERSION
export NAMESPACE SUBDOMAIN

VERSION_COLOUR="${FRONTEND_VERSION//./-}"
echo "$VERSION_COLOUR"

echo "Deploying frontend version: $FRONTEND_VERSION to namespace: $NAMESPACE..."

# Apply deployment with substituted environment variables
envsubst < deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply frontend deployment with substituted environment variables
envsubst < frontend/deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

# Apply service definition
envsubst < ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -

##Apply prod_ingress to blue
envsubst < prod_ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


echo "Deployment of '$SUBDOMAIN' complete."