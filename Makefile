# --- Configuration ---
IMAGE_NAME := hello-node-app
TAR_FILE   := $(IMAGE_NAME).tar
PACKER_DIR := packer
NERDCTL    := nerdctl

# --- Main Targets ---
.PHONY: all build test run-dev run-prod stop clean help

# Default target: Build and run the test suite
all: build test

## 1. Build: Triggers Packer to build the image via nerdctl and export the tarball
build:
	@echo "==> Building with Packer (using static Dockerfile)..."
	packer build $(PACKER_DIR)/build.pkr.hcl

## 2. Test: Runs the verification script against a temporary container
test:
	@echo "==> Running automated tests..."
	@chmod +x test-app.sh
	./test-app.sh

## 3. Run-Dev: Starts the container in development mode (Port 3001)
run-dev:
	@echo "==> Starting DEV container on http://localhost:3001"
	$(NERDCTL) run -d --name node-dev \
		-p 3001:3000 \
		-e NODE_ENV=development \
		$(IMAGE_NAME):latest

## 4. Run-Prod: Starts the container in production mode (Port 8080)
run-prod:
	@echo "==> Starting PROD container on http://localhost:8080"
	$(NERDCTL) run -d --name node-prod \
		-p 8080:3000 \
		-e NODE_ENV=production \
		$(IMAGE_NAME):latest

## 5. Stop: Stops and removes development and production containers
stop:
	@echo "==> Stopping all project containers..."
	-$(NERDCTL) stop node-dev node-prod
	-$(NERDCTL) rm node-dev node-prod

## 6. Clean: Wipes the exported tarball and stops containers
clean: stop
	@echo "==> Cleaning up artifacts..."
	rm -f $(TAR_FILE)

## Help: Displays available commands
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'