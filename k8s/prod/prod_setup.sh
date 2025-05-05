sh ./deploy.sh "prod-blue" "1.0.1"

kubectl apply -f prod_ingress.yaml --namespace "prod-blue"

