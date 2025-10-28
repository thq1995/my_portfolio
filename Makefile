.PHONY: help build up down restart logs clean test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	docker compose build

up: ## Start the application
	docker compose up -d
	@echo "Portfolio is running at http://localhost"

down: ## Stop the application
	dockercompose down

restart: down up ## Restart the application

logs: ## View application logs
	docker compose logs -f portfolio

logs-tail: ## View last 100 lines of logs
	docker compose logs --tail=100 portfolio

ps: ## Show running containers
	docker compose ps

shell: ## Open shell in container
	docker compose exec portfolio sh

clean: ## Remove containers, images, and volumes
	docker compose down -v
	docker rmi my_portfolio 2>/dev/null || true

rebuild: clean build up ## Clean rebuild and restart

test: ## Test if the application is responding
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost || echo "Application not running"

dev: ## Run development server locally
	npm run dev

install: ## Install dependencies
	npm install

deploy: build up ## Build and deploy

health: ## Check container health
	@docker inspect --format='{{.State.Health.Status}}' my_portfolio 2>/dev/null || echo "Container not running"
