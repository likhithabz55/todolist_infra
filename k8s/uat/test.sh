#!/bin/bash

# Function to check if book is present
check_book_in_db() {
  BOOKS_RESPONSE=$(curl -s -X GET http://uat-green.to-do.works:8082/)
  if [[ "$BOOKS_RESPONSE" == *"Superman Returns!!"* ]]; then
    echo $BOOKS_RESPONSE
    return 0  # Book found
  else
    return 1  # Book not found
  fi
}

# Step 1: Add a new book via frontend
BOOK_DATA='{"title": "Superman Returns!!", "description": "New Adventures of Superman","price": 19.99, "cover": "test-cover-url"}'

set -x
for ((i=1; i<=5; i++)); do
  ADD_BOOK_RESPONSE=$(curl -v -s -X POST -H "Content-Type: application/json" -d "$BOOK_DATA" http://localhost:8800/books)
  if [ $? -eq 0 ]; then
    echo "Request successful"
    break
  fi
  echo "Retrying in ..5. Attempt $i"
  sleep 5
done
set +x

# Step 2: Retry fetching the list of books if database is down or slow
MAX_RETRIES=15
RETRY_DELAY=10  # in seconds
sleep $RETRY_DELAY

set -x
for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt $i to fetch books from the database..."
  if check_book_in_db; then
    echo "Test passed: Book was added successfully!"
    exit 0
  else
    echo "Book not found, retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
  fi
done
set +x

# Step 3: If all retries fail
echo "Test failed: Could not find the book in the database after $MAX_RETRIES attempts."
exit 1