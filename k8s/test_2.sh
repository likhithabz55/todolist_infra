#!/bin/bash

# Step 1: Add a new users via /users/signup
USER_DATA='{"username": "testuser", "email": "test@example.com","password": "1234"}'


set -x
for ((i=1; i<=20; i++)); do
  ADD_USER_RESPONSE=$(curl -v -s -X POST -H "Content-Type: application/json" -d "$USER_DATA" http://uat-green.to-do.works/users/signup)
  if [ $? -eq 0 ]; then
    echo "Signup successful"
    break
  fi
  echo "Retrying in ..5. Attempt $i"
  sleep 5
done
set +x

set -x
for ((i=1; i<=20; i++)); do
  ADD_USER_RESPONSE=$(curl -v -s -X POST -H "Content-Type: application/json" -d '{"username": "testuser", "password": "1234"}' http://uat-green.to-do.works/users/login)
  if [ $? -eq 0 ]; then
    echo "login successful"
    break
  fi
  echo "Retrying in ..5. Attempt $i"
  sleep 5
done
set +x

set -x
for ((i=1; i<=20; i++)); do
  VIEW_TASKS_RESPONSE=$(curl -v -s -X GET http://uat-green.to-do.works/tasks/viewTasks?username=testuser)
  if [ $? -eq 0 ]; then
    echo "Request successful"
    break
  fi
  echo "Retrying in ..5. Attempt $i"
  sleep 5
done
set +x

