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

## 🌊 DigitalOcean Droplet Deployment

### Prerequisites
- DigitalOcean droplet with SSH access
- Your droplet's IP address
- SSL certificates in `.ssh/` directory

### Quick Deployment
1. **Update the deployment script** with your droplet IP:
   ```bash
   # Edit deploy-digitalocean.sh and change:
   DROPLET_IP="YOUR_DROPLET_IP_HERE"
   # to your actual droplet IP address
   ```

2. **Run the deployment script**:
   ```bash
   ./deploy-digitalocean.sh
   ```

3. **Copy SSL certificates** to the droplet:
   ```bash
   scp .ssh/cert.pem root@YOUR_DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/
   scp .ssh/key.pem root@YOUR_DROPLET_IP:/opt/antidote/antidoteNextjs/.ssh/
   ```

4. **Restart nginx** to load SSL certificates:
   ```bash
   ssh root@YOUR_DROPLET_IP 'cd /opt/antidote/antidoteNextjs && docker-compose -f docker-compose.prod.yml restart nginx'
   ```

### Manual Deployment Steps
If you prefer to deploy manually:

1. **SSH into your droplet**:
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Install Docker and Docker Compose**:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   ```

3. **Clone the repository**:
   ```bash
   mkdir -p /opt/antidote
   cd /opt/antidote
   git clone https://github.com/randycollier/antidoteNextjs.git
   cd antidoteNextjs
   git submodule update --init --recursive
   ```

4. **Copy SSL certificates** and start services:
   ```bash
   mkdir -p .ssh
   # Copy your cert.pem and key.pem files to .ssh/
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

### Droplet Management
- **View logs**: `docker-compose -f docker-compose.prod.yml logs -f`
- **Restart services**: `docker-compose -f docker-compose.prod.yml restart`
- **Update application**: `git pull origin main && git submodule update --init --recursive && docker-compose -f docker-compose.prod.yml up -d --build`

## 📁 Project Structure

```
antidoteNextjs/
├── antidote_design/          # Next.js application (Git submodule)
├── nginx/                    # Nginx configuration
│   ├── nginx.conf           # Local development config
│   ├── nginx.prod.conf      # Production config with SSL
│   └── Dockerfile           # Nginx container
├── docker-compose.yml        # Local development
├── docker-compose.prod.yml  # Production deployment
├── setup-local.sh           # Local setup script
├── deploy-prod.sh           # Production deployment script
├── deploy-digitalocean.sh   # DigitalOcean droplet deployment
└── .ssh/                    # SSL certificates (not in git)
```

## 🔄 Making Changes

This project uses a Git submodule structure where `antidote_design` is a separate repository containing your Next.js application. Here's how to work with it:

### Making Changes to the Next.js App

1. **Navigate to the submodule:**
   ```bash
   cd antidote_design
   ```

2. **Make your changes** to the Next.js code

3. **Commit and push the submodule:**
   ```bash
   git add .
   git commit -m "Your commit message"
   git push origin main
   ```

4. **Update the main repository** to reference the new submodule commits:
   ```bash
   cd ..
   git add antidote_design
   git commit -m "Update antidote_design submodule"
   git push origin main
   ```

### Making Changes to Docker/Infrastructure

1. **Stay in the main repository:**
   ```bash
   # You're already in antidoteNextjs/
   ```

2. **Make your changes** to Docker files, nginx config, etc.

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Your commit message"
   git push origin main
   ```

### Workflow Summary

- **Next.js changes**: `antidote_design/` → commit → push submodule → update main repo
- **Infrastructure changes**: main repo → commit → push
- **Always commit submodule changes first, then update the main repo**

### Cloning the Project

When someone clones this project, they need to initialize the submodule:

```bash
git clone https://github.com/randycollier/antidoteNextjs.git
cd antidoteNextjs
git submodule update --init --recursive
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
