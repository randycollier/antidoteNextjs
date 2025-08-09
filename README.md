# Antidote Next.js Project

This project is set up to run both locally and in production with SSL support.

## 🏠 Local Development

### Prerequisites
- Docker and Docker Compose installed
- macOS (for automatic hosts file setup)

### Quick Start
1. Run the setup script:
   ```bash
   ./setup-local.sh
   ```

2. Access your app at: http://antidote-design.local:3030

### Manual Setup
If you prefer manual setup:

1. Add to your hosts file (`/etc/hosts` on macOS/Linux):
   ```
   127.0.0.1 antidote-design.local
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Access at: http://antidote-design.local:3030

### Local Commands
- Start services: `docker-compose up -d`
- Stop services: `docker-compose down`
- View logs: `docker-compose logs -f`
- Rebuild: `docker-compose up -d --build`

## 🚀 Production Deployment (DigitalOcean)

### Prerequisites
- SSL certificates in `.ssh/` directory:
  - `.ssh/cert.pem` (SSL certificate)
  - `.ssh/key.pem` (SSL private key)

### Deploy
1. Ensure your SSL certificates are in the `.ssh/` directory
2. Run the deployment script:
   ```bash
   ./deploy-prod.sh
   ```

### Production Commands
- Start: `docker-compose -f docker-compose.prod.yml up -d`
- Stop: `docker-compose -f docker-compose.prod.yml down`
- Logs: `docker-compose -f docker-compose.prod.yml logs -f`
- Rebuild: `docker-compose -f docker-compose.prod.yml up -d --build`

## 📁 Project Structure

```
antidoteNextjs/
├── antidote_design/          # Next.js application
├── nginx/                    # Nginx configuration
│   ├── nginx.conf           # Local development config
│   ├── nginx.prod.conf      # Production config with SSL
│   └── Dockerfile           # Nginx container
├── docker-compose.yml        # Local development
├── docker-compose.prod.yml  # Production deployment
├── setup-local.sh           # Local setup script
├── deploy-prod.sh           # Production deployment script
└── .ssh/                    # SSL certificates (not in git)
```

## 🔒 SSL Configuration

The production setup expects SSL certificates in the `.ssh/` directory:
- `cert.pem`: Your SSL certificate
- `key.pem`: Your private key

These files are mounted into the nginx container and used for HTTPS termination.

## 🌐 Domain Configuration

- **Local**: `antidote-design.local:3030` (automatically added to hosts file)
- **Production**: Configure your domain in DigitalOcean and point it to your server

## 🐛 Troubleshooting

### Local Issues
- If you can't access `antidote-design.local:3030`, check your hosts file
- Ensure Docker services are running: `docker-compose ps`

### Production Issues
- Verify SSL certificates exist in `.ssh/` directory
- Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`
- Ensure ports 80 and 443 are open on your DigitalOcean droplet

### General Issues
- Rebuild containers: `docker-compose up -d --build`
- Check container status: `docker-compose ps`
- View logs: `docker-compose logs -f [service-name]`
