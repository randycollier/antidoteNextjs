FROM nginx:alpine

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80 || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# Labels for GitHub Container Registry
LABEL org.opencontainers.image.source="https://github.com/randycollier/antidoteNextjs"
LABEL org.opencontainers.image.description="Antidote Design Nginx Reverse Proxy"
LABEL org.opencontainers.image.licenses="MIT"
