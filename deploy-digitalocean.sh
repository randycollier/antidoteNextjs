#!/bin/bash

# DigitalOcean Deployment Script
# This script deploys the antidoteNextjs application to a DigitalOcean droplet

set -e  # Exit on any error

# Configuration file
CONFIG_FILE="droplet.config"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file '$CONFIG_FILE' not found!"
    echo "   Please copy 'droplet.config' and fill in your droplet details:"
    echo "   cp droplet.config droplet.config.local"
    echo "   # Then edit droplet.config.local with your IP and SSH user"
    exit 1
fi

# Load configuration
echo "📋 Loading configuration from $CONFIG_FILE..."
source "$CONFIG_FILE"

# Validate required variables
if [ -z "$DROPLET_IP" ] || [ "$DROPLET_IP" = "YOUR_DROPLET_IP_HERE" ]; then
    echo "❌ Error: DROPLET_IP not configured in $CONFIG_FILE!"
    echo "   Please set DROPLET_IP to your droplet's IP address"
    exit 1
fi

if [ -z "$SSH_USER" ] || [ "$SSH_USER" = "YOUR_SSH_USER_HERE" ]; then
    echo "❌ Error: SSH_USER not configured in $CONFIG_FILE!"
    echo "   Please set SSH_USER (usually 'root' for DigitalOcean)"
    exit 1
fi

echo "🚀 Deploying to DigitalOcean droplet..."
echo "📍 Droplet IP: $DROPLET_IP"
echo "👤 SSH User: $SSH_USER"
echo "📦 Repository: $REPO_URL"
echo ""

echo "📡 Connecting to droplet at $DROPLET_IP..."

# Deploy to DigitalOcean droplet
ssh -o StrictHostKeyChecking=no $SSH_USER@$DROPLET_IP << 'EOF'
    echo "🔧 Updating system packages..."
    apt update && apt upgrade -y
    
    echo "🐳 Installing Docker and Docker Compose..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        usermod -aG docker $USER
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    echo "📁 Creating project directory..."
    mkdir -p /opt/antidote
    cd /opt/antidote
    
    echo "📥 Cloning main repository..."
    if [ -d "antidoteNextjs" ]; then
        cd antidoteNextjs
        git pull origin main
    else
        git clone $REPO_URL
        cd antidoteNextjs
    fi
    
    echo "📥 Initializing submodule..."
    git submodule update --init --recursive
    
    echo "🔒 Setting up SSL certificates..."
    mkdir -p .ssh
    echo "⚠️  IMPORTANT: You need to manually copy your SSL certificates to the droplet:"
    echo "   scp .ssh/cert.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/"
    echo "   scp .ssh/key.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/"
    
    echo "🚀 Building and starting production services..."
    docker-compose -f docker-compose.prod.yml down || true
    docker-compose -f docker-compose.prod.yml up -d --build
    
    echo "✅ Deployment complete!"
    echo "🌐 Your app should be available at:"
    echo "   - HTTP:  http://$DROPLET_IP"
    echo "   - HTTPS: https://$DROPLET_IP (if SSL certificates are configured)"
    
    echo "📊 Container status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo "📝 To view logs: docker-compose -f docker-compose.prod.yml logs -f"
    echo "🛑 To stop: docker-compose -f docker-compose.prod.yml down"
EOF

echo ""
echo "🎉 Deployment script completed!"
echo ""
echo "📋 Next steps:"
echo "1. Copy your SSL certificates to the droplet:"
echo "   scp .ssh/cert.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/"
echo "   scp .ssh/key.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/"
echo ""
echo "2. Restart the services after copying certificates:"
echo "   ssh $SSH_USER@$DROPLET_IP 'cd /opt/antidote/antidoteNextjs && docker-compose -f docker-compose.prod.yml restart nginx'"
echo ""
echo "3. Access your app at: https://$DROPLET_IP"
