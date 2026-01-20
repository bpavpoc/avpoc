#!/bin/bash
# test-app.sh

IMAGE_NAME="avpoc-hello-node-app"
APP_NAME="node-test-instance"
TEST_NAME="DevOpsEngineer"
PORT=3001

echo "--- 1. Cleaning up old tests ---"
nerdctl stop $APP_NAME > /dev/null 2>&1 || true
nerdctl rm $APP_NAME > /dev/null 2>&1 || true

echo "--- 2. Starting container in Dev mode ---"
# Mapping host 3001 to internal 3000
nerdctl run -d --name $APP_NAME -p $PORT:3000 -e NODE_ENV=development $IMAGE_NAME:latest

echo "--- 3. Verifying nerdctl port mapping ---"
MAX_PORT_RETRIES=10
for i in $(seq 1 $MAX_PORT_RETRIES); do
    # Verify the rootless forwarder is active
    if nerdctl port $APP_NAME | grep -q "3000/tcp -> 0.0.0.0:$PORT"; then
        echo "SUCCESS: nerdctl confirmed port $PORT is mapped."
        break
    fi
    if [ $i -eq $MAX_PORT_RETRIES ]; then
        echo "FAILURE: Port mapping failed to initialize."
        nerdctl logs $APP_NAME
        exit 1
    fi
    echo "Attempt $i: Waiting for port mapping..."
    sleep 2
done

echo "--- 4. Waiting for server to spin up... ---"
URL="http://localhost:$PORT/hello/$TEST_NAME"
MAX_RETRIES=15
for i in $(seq 1 $MAX_RETRIES); do
    if curl -sSf "$URL" > /dev/null 2>&1; then
        echo "--- Server is UP ---"
        break
    fi
    if [ $i -eq $MAX_RETRIES ]; then
        echo "FAILURE: App did not respond at $URL"
        nerdctl logs $APP_NAME
        exit 1
    fi
    echo "Attempt $i/$MAX_RETRIES: Waiting for $URL..."
    sleep 2
done

echo "--- 5. Testing Endpoint: $URL ---"
RESPONSE=$(curl -s "$URL")

# Verbose check for the specific TEST_NAME
if [[ $RESPONSE == *"$TEST_NAME"* ]]; then
    echo "SUCCESS: App returned expected name: $TEST_NAME"
    echo "Response Snippet: $(echo $RESPONSE | grep -o "<h1>Hello, .*!</h1>")"
    
    # Branch Coverage Check: Verify Dev Color
    if [[ $RESPONSE == *"#f39c12"* ]]; then
        echo "VERIFIED: Development styling confirmed (#f39c12)."
    fi
else
    echo "FAILURE: App did not respond correctly."
    echo "Full Response for Debug: $RESPONSE"
    exit 1
fi

echo "--- 6. Tearing down test container ---"
nerdctl stop $APP_NAME
nerdctl rm $APP_NAME
echo "Test Passed for $TEST_NAME!"