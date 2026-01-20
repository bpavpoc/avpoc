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
nerdctl run -d --name $APP_NAME -p $PORT:3000 -e NODE_ENV=development $IMAGE_NAME:latest

echo "--- 3. Waiting for server to spin up... ---"
sleep 3

echo "--- 4. Testing Endpoint: http://localhost:$PORT/hello/$TEST_NAME ---"
RESPONSE=$(curl -s http://localhost:$PORT/hello/$TEST_NAME)

if [[ $RESPONSE == *"$TEST_NAME"* ]]; then
    echo "SUCCESS: App returned expected name!"
    echo "Response Snippet: $(echo $RESPONSE | head -c 50)..."
else
    echo "FAILURE: App did not respond correctly."
    exit 1
fi

echo "--- 5. Tearing down test container ---"
nerdctl stop $APP_NAME
nerdctl rm $APP_NAME
echo "Test Passed!"