aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 822298509516.dkr.ecr.us-east-1.amazonaws.com

#tag images
docker tag todolist-app/frontend:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/frontend:latest
docker tag todolist-app/user-service:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/user_service:latest
docker tag todolist-app/taskview-service:latest 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/taskview_service:latest

#push

docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/frontend:latest
docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/user_service:latest
docker push 822298509516.dkr.ecr.us-east-1.amazonaws.com/blue_green_ecr/taskview_service:latest
