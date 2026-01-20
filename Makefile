# --- Configuration ---
IMAGE_NAME := hello-node-app
TAR_FILE   := $(IMAGE_NAME).tar
PACKER_DIR := packer
NERDCTL    := nerdctl

# --- Main Targets ---
.PHONY: all build test run-dev run-prod stop clean help

all: build test ## [Default] Build and run the test suite

scan: ## SonarQube quality gate scan
	@echo "==> Running SonarQube Scan..."
	$(NERDCTL) run --rm \
		-e SONAR_HOST_URL="$(SONAR_HOST_URL)" \
		-e SONAR_LOGIN="$(SONAR_TOKEN)" \
		-v "$(PWD):/usr/src" \
		sonarsource/sonar-scanner-cli
	@echo "Check your SonarQube dashboard for the Quality Gate result."

build: ## Triggers Packer to build the image via nerdctl and export the tarball
	@echo "==> Building with Packer..."
	packer build $(PACKER_DIR)/build.pkr.hcl

test: ## Runs the verification script against a temporary container
	@echo "==> Running automated tests..."
	@chmod +x test/test-app.sh
	test/test-app.sh

run-dev: ## Starts the container in development mode (Port 3001)
	@echo "==> Starting DEV container on http://localhost:3001"
	$(NERDCTL) run -d --name node-dev \
		-p 3001:3000 \
		-e NODE_ENV=development \
		$(IMAGE_NAME):latest

run-prod: ## Starts the container in production mode (Port 8080)
	@echo "==> Starting PROD container on http://localhost:8080"
	$(NERDCTL) run -d --name node-prod \
		-p 8080:3000 \
		-e NODE_ENV=production \
		$(IMAGE_NAME):latest

stop: ## Stops and removes development and production containers
	@echo "==> Stopping all project containers..."
	-$(NERDCTL) stop node-dev node-prod
	-$(NERDCTL) rm node-dev node-prod

clean: stop ## Wipes the exported tarball and stops containers
	@echo "==> Cleaning up artifacts..."
	rm -f $(TAR_FILE)

help: ## Displays available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'