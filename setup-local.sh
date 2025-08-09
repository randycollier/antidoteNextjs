#!/bin/bash

echo "Setting up local environment for antidote-design.local..."

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Setting up hosts file entry..."
    
    # Check if entry already exists
    if grep -q "antidote-design.local" /etc/hosts; then
        echo "Hosts file entry already exists."
    else
        echo "Adding entry to /etc/hosts..."
        echo "127.0.0.1 antidote-design.local" | sudo tee -a /etc/hosts
        echo "Hosts file updated successfully!"
    fi
    
    echo "Starting Docker services..."
    docker-compose up -d
    
    echo ""
    echo "✅ Setup complete! Your app should be available at:"
    echo "   http://antidote-design.local:3030"
    echo ""
    echo "To stop the services, run: docker-compose down"
    echo "To view logs, run: docker-compose logs -f"
    
else
    echo "This script is designed for macOS. Please manually add the following line to your hosts file:"
    echo "127.0.0.1 antidote-design.local"
    echo ""
    echo "Then run: docker-compose up -d"
fi
