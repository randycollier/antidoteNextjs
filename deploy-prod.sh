#!/bin/bash

echo "🚀 Deploying to production..."

# Check if SSL certificates exist
if [ ! -f ".ssh/cert.pem" ] || [ ! -f ".ssh/key.pem" ]; then
    echo "❌ Error: SSL certificates not found in .ssh/ directory"
    echo "Please ensure you have the following files:"
    echo "  - .ssh/cert.pem (SSL certificate)"
    echo "  - .ssh/key.pem (SSL private key)"
    exit 1
fi

echo "✅ SSL certificates found"

# Build and start production services
echo "Building and starting production services..."
docker-compose -f docker-compose.prod.yml up -d --build

echo ""
echo "✅ Production deployment complete!"
echo ""
echo "Your app should now be running with SSL enabled."
echo "To view logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "To stop services: docker-compose -f docker-compose.prod.yml down"
