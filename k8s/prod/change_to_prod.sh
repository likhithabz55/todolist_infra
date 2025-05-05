#!/bin/bash

# Usage: ./promote.sh <from-namespace> <to-namespace>
# Example: ./promote.sh blue green

FROM_NAMESPACE=$1
TO_NAMESPACE=$2

if [[ -z "$FROM_NAMESPACE" || -z "$TO_NAMESPACE" ]]; then
  echo "Usage: $0 <from-namespace> <to-namespace>"
  exit 1
fi

echo "Promoting from namespace '$FROM_NAMESPACE' to namespace '$TO_NAMESPACE'..."

# Remove the current ingress from the source namespace
kubectl delete ingress proxy-prod-ingress --namespace "$FROM_NAMESPACE"

# Apply production service in the target namespace
kubectl apply -f prod_ingress.yaml --namespace "$TO_NAMESPACE"

echo "Promotion complete."
