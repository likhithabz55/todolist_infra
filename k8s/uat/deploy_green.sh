#!/bin/bash

aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

NAMESPACE="uat-green"
#SUBDOMAIN="uat-green"


###EXTRACT LATEST TAG

REPO_NAME_1="blue_green_ecr/frontend"
REPO_NAME_2="blue_green_ecr/user_service"
REPO_NAME_3="blue_green_ecr/taskview_service"
AWS_REGION="us-east-1"

FRONTEND_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME_1 \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

echo "$FRONTEND_VERSION"

USER_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME_2 \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)


echo "$USER_VERSION"

TASK_VERSION=$(aws ecr describe-images \
  --repository-name $REPO_NAME_3 \
  --region $AWS_REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text | tr '\t' '\n' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)


echo "$TASK_VERSION"

export FRONTEND_VERSION USER_VERSION TASK_VERSION
export NAMESPACE
#export SUBDOMAIN

echo "Deploying green version: $FRONTEND_VERSION to namespace: $NAMESPACE..."

# Apply frontend deployment with substituted environment variables
envsubst < deployment.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


# Apply service definition
envsubst < ingress.yaml | kubectl apply --namespace "$NAMESPACE" --filename -


