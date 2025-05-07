aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 822298509516.dkr.ecr.us-east-1.amazonaws.com

#tag images
docker tag todolist-app/frontend:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/frontend:1.3.0
docker tag todolist-app/user-service:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/user_service:1.3.0
docker tag todolist-app/taskview-service:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/taskview_service:1.3.0

#push

docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/frontend:1.3.0
docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/user_service:1.3.0
docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/taskview_service:1.3.0
