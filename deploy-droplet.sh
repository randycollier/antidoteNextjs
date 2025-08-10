#!/bin/bash

# Deploy to DigitalOcean Droplet
# This script pulls and runs Docker images from GHCR on your droplet

set -e

# Configuration
GITHUB_USERNAME="randycollier"
REGISTRY="ghcr.io"
PROJECT_NAME="antidote-design"
DOMAIN="antidote-design.net"  # Update this to your actual domain

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Antidote Design to DigitalOcean Droplet...${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Create deployment directory
DEPLOY_DIR="/opt/antidote-design"
echo -e "${YELLOW}📁 Creating deployment directory...${NC}"
mkdir -p $DEPLOY_DIR
mkdir -p $DEPLOY_DIR/ssl
mkdir -p $DEPLOY_DIR/logs
cd $DEPLOY_DIR

# Create docker-compose file for production
echo -e "${YELLOW}📝 Creating docker-compose.yml...${NC}"
cat > docker-compose.yml << EOF
version: '3.8'

services:
  nextjs:
    image: $REGISTRY/$GITHUB_USERNAME/$PROJECT_NAME:latest
    container_name: antidote-nextjs
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: unless-stopped
    networks:
      - antidote-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest
    container_name: antidote-nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - nextjs
    restart: unless-stopped
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
    networks:
      - antidote-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  antidote-network:
    driver: bridge

volumes:
  ssl:
  logs:
EOF

# Create nginx configuration
echo -e "${YELLOW}📝 Creating nginx configuration...${NC}"
cat > nginx.conf << EOF
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server with SSL
server {
    listen 443 ssl;
    http2 on;
    server_name $DOMAIN www.$DOMAIN;

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # SSL security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location / {
        proxy_pass http://nextjs:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-XSS-Protection "1; mode=block";
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port 443;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /_next/static {
        proxy_pass http://nextjs:3000;
        proxy_set_header Host \$host;
        expires 365d;
        access_log off;
        add_header Cache-Control "public, immutable";
    }

    location /static {
        proxy_pass http://nextjs:3000;
        proxy_set_header Host \$host;
        expires 365d;
        access_log off;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Check if SSL certificates exist
if [ ! -f "./ssl/cert.pem" ] || [ ! -f "./ssl/key.pem" ]; then
    echo -e "${YELLOW}⚠️  SSL certificates not found. Creating self-signed certificates for testing...${NC}"
    echo -e "${YELLOW}   For production, please add your SSL certificates to ./ssl/cert.pem and ./ssl/key.pem${NC}"
    
    # Create self-signed certificate for testing
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ./ssl/key.pem \
        -out ./ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"
fi

# Set proper permissions
chmod 600 ./ssl/*
chmod 644 ./ssl/cert.pem

# Pull latest images
echo -e "${YELLOW}📥 Pulling latest images from GHCR...${NC}"
docker pull $REGISTRY/$GITHUB_USERNAME/$PROJECT_NAME:latest
docker pull $REGISTRY/$GITHUB_USERNAME/antidote-nginx:latest

# Stop and remove existing containers if they exist
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker compose down --remove-orphans 2>/dev/null || true

# Remove old images to save space
echo -e "${YELLOW}🧹 Cleaning up old images...${NC}"
docker image prune -f

# Start the services
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker compose up -d

# Wait for services to be healthy
echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"
sleep 10

# Check service status
echo -e "${YELLOW}📊 Checking service status...${NC}"
docker compose ps

# Check logs
echo -e "${YELLOW}📋 Recent logs:${NC}"
docker compose logs --tail=20

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
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Service Information:${NC}"
echo "   Next.js: http://localhost:3000 (internal)"
echo "   Nginx:   http://localhost:80 (HTTP) / https://localhost:443 (HTTPS)"
echo "   Domain:  $DOMAIN"
echo ""
echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "   View logs:     cd $DEPLOY_DIR && docker compose logs -f"
echo "   Restart:       cd $DEPLOY_DIR && docker compose restart"
echo "   Stop:          cd $DEPLOY_DIR && docker compose down"
echo "   Update:        cd $DEPLOY_DIR && ./deploy-droplet.sh"
echo ""
echo -e "${BLUE}📁 Files created:${NC}"
echo "   Directory:     $DEPLOY_DIR"
echo "   Compose file:  $DEPLOY_DIR/docker-compose.yml"
echo "   Nginx config:  $DEPLOY_DIR/nginx.conf"
echo "   SSL certs:     $DEPLOY_DIR/ssl/"
echo ""
echo -e "${YELLOW}⚠️  Remember to:${NC}"
echo "   1. Update your domain DNS to point to this droplet's IP"
echo "   2. Replace self-signed SSL certificates with real ones for production"
echo "   3. Configure firewall rules if needed"
echo "   4. Set up monitoring and backups"
