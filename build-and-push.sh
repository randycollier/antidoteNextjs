#!/bin/bash

# Build and Push to GitHub Container Registry
# This script builds and pushes Docker images to GHCR

set -e

# Configuration
GITHUB_USERNAME="randycollier"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REGISTRY="ghcr.io"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ Error: GITHUB_TOKEN environment variable not set!${NC}"
    echo ""
    echo "Please set your GitHub Personal Access Token:"
    echo "export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "Or create a .env file with:"
    echo "GITHUB_TOKEN=your_token_here"
    echo ""
    echo "Token needs these permissions:"
    echo "- write:packages"
    echo "- read:packages"
    echo "- delete:packages (optional)"
    exit 1
fi

echo -e "${GREEN}🚀 Building and pushing to GitHub Container Registry...${NC}"
echo ""

# Login to GHCR
echo -e "${YELLOW}🔐 Logging in to GHCR...${NC}"
echo "$GITHUB_TOKEN" | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin

# Build and push Next.js app
echo -e "${YELLOW}🔨 Building Next.js application...${NC}"
cd antidote_design
docker build --platform linux/amd64 -t $REGISTRY/$GITHUB_USERNAME/antidote-design:latest .
docker build --platform linux/amd64 -t $REGISTRY/$GITHUB_USERNAME/antidote-design:$(git rev-parse --short HEAD) .

echo -e "${YELLOW}📤 Pushing Next.js application...${NC}"
docker push $REGISTRY/$GITHUB_USERNAME/antidote-design:latest
docker push $REGISTRY/$GITHUB_USERNAME/antidote-design:$(git rev-parse --short HEAD)
cd ..

# Build and push Nginx
echo -e "${YELLOW}🔨 Building Nginx...${NC}"
cd nginx
docker build --platform linux/amd64 -t $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest .
docker build --platform linux/amd64 -t $REGISTRY/$GITHUB_USERNAME/antidote-nginx:$(git rev-parse --short HEAD) .

echo -e "${YELLOW}📤 Pushing Nginx...${NC}"
docker push $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest
docker push $REGISTRY/$GITHUB_USERNAME/antidote-nginx:$(git rev-parse --short HEAD)
cd ..

echo ""
echo -e "${GREEN}✅ All images built and pushed successfully!${NC}"
echo ""
echo "📋 Image URLs:"
echo "   Next.js: $REGISTRY/$GITHUB_USERNAME/antidote-design:latest"
echo "   Nginx:   $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest"
echo ""
echo "🔍 View your packages at:"
echo "   https://github.com/$GITHUB_USERNAME?tab=packages"
echo ""
echo "📝 To use these images in production, update your docker-compose.prod.yml:"
echo "   image: $REGISTRY/$GITHUB_USERNAME/antidote-design:latest"
echo "   image: $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest"
