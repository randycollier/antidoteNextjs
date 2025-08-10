#!/bin/bash

# Update DigitalOcean Droplet
# This script pulls latest images and restarts services

set -e

# Configuration
GITHUB_USERNAME="randycollier"
REGISTRY="ghcr.io"
PROJECT_NAME="antidote-design"
DEPLOY_DIR="/opt/antidote-design"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Updating Antidote Design on DigitalOcean Droplet...${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Change to deployment directory
cd $DEPLOY_DIR

# Pull latest images
echo -e "${YELLOW}📥 Pulling latest images from GHCR...${NC}"
docker pull $REGISTRY/$GITHUB_USERNAME/$PROJECT_NAME:latest
docker pull $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest

# Restart services with new images
echo -e "${YELLOW}🔄 Restarting services with new images...${NC}"
docker compose down
docker compose up -d

# Wait for services to be healthy
echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"
sleep 10

# Check service status
echo -e "${YELLOW}📊 Checking service status...${NC}"
docker compose ps

# Test the deployment
echo -e "${YELLOW}🧪 Testing deployment...${NC}"
if curl -f -s http://localhost/health > /dev/null; then
    echo -e "${GREEN}✅ HTTP health check passed${NC}"
else
    echo -e "${RED}❌ HTTP health check failed${NC}"
fi

if curl -f -s -k https://localhost/health > /dev/null; then
    echo -e "${GREEN}✅ HTTPS health check passed${NC}"
else
    echo -e "${RED}❌ HTTPS health check failed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Update completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Service Information:${NC}"
echo "   Next.js: http://localhost:3000 (internal)"
echo "   Nginx:   http://localhost:80 (HTTP) / https://localhost:443 (HTTPS)"
echo ""
echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "   View logs:     docker compose logs -f"
echo "   Restart:       docker compose restart"
echo "   Stop:          docker compose down"
echo "   Full deploy:   ./deploy-droplet.sh"
