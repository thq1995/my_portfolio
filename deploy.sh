#!/bin/bash

# Portfolio Deployment Script
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is running"

# Stop and remove existing container
echo -e "${YELLOW}⏸️  Stopping existing containers...${NC}"
docker compose down 2>/dev/null || true

# Clean up old images (optional)
echo -e "${YELLOW}🧹 Cleaning up old images...${NC}"
docker image prune -f

# Build new image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker compose build --no-cache

# Start the application
echo -e "${YELLOW}🚀 Starting application...${NC}"
docker compose up -d

# Wait for health check
echo -e "${YELLOW}⏳ Waiting for health check...${NC}"
sleep 10

# Check container status
if docker compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓${NC} Container is running"
else
    echo -e "${RED}❌ Container failed to start${NC}"
    docker compose logs --tail=50
    exit 1
fi

# Check health status
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' my_portfolio 2>/dev/null || echo "unknown")
echo -e "Health Status: ${HEALTH_STATUS}"

# Show logs
echo -e "\n${GREEN}📋 Recent logs:${NC}"
docker compose logs --tail=20

echo -e "\n${GREEN}✅ Deployment complete!${NC}"
echo -e "Portfolio is running at: ${GREEN}http://localhost${NC}"
echo -e "\nUseful commands:"
echo -e "  View logs:    ${YELLOW}docker compose logs -f${NC}"
echo -e "  Stop app:     ${YELLOW}docker compose down${NC}"
echo -e "  Restart:      ${YELLOW}docker compose restart${NC}"
echo -e "  Check health: ${YELLOW}docker inspect --format='{{.State.Health.Status}}' my_portfolio${NC}"
