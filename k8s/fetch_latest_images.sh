#!/bin/bash

###EXTRACT LATEST TAG

REPO_NAME_1="blue_green_ecr/frontend"
REPO_NAME_2="blue_green_ecr/user_service"
REPO_NAME_3="blue_green_ecr/taskview_service"
AWS_REGION="us-east-1"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 822298509516.dkr.ecr.us-east-1.amazonaws.com

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

export FRONTEND_VERSION TASK_VERSION USER_VERSION