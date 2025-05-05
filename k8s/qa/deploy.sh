aws eks update-kubeconfig --region us-east-1 --name eks-blue-green

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

echo "Deploying frontend version: $FRONTEND_VERSION to namespace: qa"

envsubst < deployment.yaml | kubectl apply -f -




##