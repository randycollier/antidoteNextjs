#!/bin/bash

# SSL Certificate Copy Script
# This script copies SSL certificates to your DigitalOcean droplet

set -e

# Configuration file
CONFIG_FILE="droplet.config"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file '$CONFIG_FILE' not found!"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"

# Check if certificates exist locally
if [ ! -f ".ssh/cert.pem" ] || [ ! -f ".ssh/key.pem" ]; then
    echo "❌ Error: SSL certificates not found in .ssh/ directory!"
    echo "   Please ensure .ssh/cert.pem and .ssh/key.pem exist"
    exit 1
fi

echo "🔒 Copying SSL certificates to droplet..."
echo "📍 Droplet IP: $DROPLET_IP"
echo "👤 SSH User: $SSH_USER"

# Copy certificates
echo "📤 Copying cert.pem..."
scp .ssh/cert.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/

echo "📤 Copying key.pem..."
scp .ssh/key.pem $SSH_USER@$DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/

echo "✅ SSL certificates copied successfully!"

echo ""
echo "🔄 Restarting nginx to load SSL certificates..."
ssh $SSH_USER@$DROPLET_IP 'cd /opt/antidote/antidoteNextjs && docker-compose -f docker-compose.prod.yml restart nginx'

echo "🎉 SSL setup complete! Your app should now be available at:"
echo "   https://$DROPLET_IP"
