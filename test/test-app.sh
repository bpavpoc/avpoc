#!/bin/bash
# test-app.sh

IMAGE_NAME="avpoc-hello-node-app"
APP_NAME="node-test-instance"
TEST_NAME="DevOpsEngineer"
PORT=3001

echo "--- 1. Cleaning up old tests ---"
nerdctl stop $APP_NAME > /dev/null 2>&1
nerdctl rm $APP_NAME > /dev/null 2>&1

echo "--- 2. Starting container in Dev mode ---"
# Note: Ensure internal port 3000 matches your app.js listener
nerdctl run -d --name $APP_NAME -p $PORT:3000 -e NODE_ENV=development $IMAGE_NAME:latest

echo "--- 3. Waiting for server to spin up (Dynamic Healthcheck) ---"
MAX_RETRIES=10
RETRY_COUNT=0
URL="http://localhost:$PORT/hello/$TEST_NAME"

# Poll the endpoint until it returns a 200 status or hits the retry limit
until $(curl -sSf "$URL" > /dev/null 2>&1); do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "FAILURE: Server failed to become healthy after $MAX_RETRIES attempts."
        nerdctl logs $APP_NAME
        exit 1
    fi
    echo "Attempt $RETRY_COUNT/$MAX_RETRIES: Waiting for $URL..."
    sleep 2
done

echo "--- 4. Testing Endpoint: $URL ---"
RESPONSE=$(curl -s "$URL")

# Improved validation: Check for the name and the expected status color
if [[ $RESPONSE == *"$TEST_NAME"* ]]; then
    echo "SUCCESS: App returned expected name!"
    # Verify the Dev environment color is present to confirm branch coverage
    if [[ $RESPONSE == *"#f39c12"* ]]; then
        echo "SUCCESS: Environment styling (Dev) confirmed."
    fi
else
    echo "FAILURE: App did not respond correctly."
    echo "Full Response for Debug: $RESPONSE"
    exit 1
fi

echo "--- 5. Tearing down test container ---"
nerdctl stop $APP_NAME
nerdctl rm $APP_NAME
echo "Test Passed!"