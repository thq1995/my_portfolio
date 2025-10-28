# Docker Deployment Guide

This portfolio is containerized using Docker and can be deployed easily with Docker Compose.

## Architecture

- **Multi-stage Docker build** for optimized image size
- **Nginx** web server serving static files
- **Next.js static export** for fast performance
- **Health checks** for container monitoring

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)

## Quick Start

### 1. Build and Run

```bash
docker-compose up -d
```

This will:
- Build the Docker image
- Start the container
- Expose the portfolio on http://localhost

### 2. View Logs

```bash
docker-compose logs -f portfolio
```

### 3. Stop the Application

```bash
docker-compose down
```

## Docker Commands

### Build Image Only
```bash
docker-compose build
```

### Rebuild from Scratch
```bash
docker-compose build --no-cache
```

### View Running Containers
```bash
docker-compose ps
```

### Execute Commands in Container
```bash
docker-compose exec portfolio sh
```

### Check Health Status
```bash
docker inspect --format='{{json .State.Health}}' my_portfolio
```

## Configuration

### Port Mapping

By default, the application runs on port 80. To change the port, edit `docker-compose.yml`:

```yaml
ports:
  - "8080:80"  # Change 8080 to your desired port
```

### Environment Variables

Add environment variables in `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - CUSTOM_VAR=value
```

### Nginx Configuration

Modify `nginx.conf` to customize:
- Caching policies
- Security headers
- Gzip compression
- URL rewrites

## Production Deployment

### With Custom Domain

1. Update `nginx.conf` server_name:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

2. Add SSL/TLS (recommended):
```yaml
# docker-compose.yml
ports:
  - "80:80"
  - "443:443"
volumes:
  - ./ssl:/etc/nginx/ssl
```

### Behind a Reverse Proxy

If using Traefik, Nginx Proxy Manager, or similar:

```yaml
services:
  portfolio:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portfolio.rule=Host(`yourdomain.com`)"
```

## Monitoring

### Container Stats
```bash
docker stats my_portfolio
```

### Nginx Access Logs
```bash
docker-compose logs portfolio | grep access
```

### Nginx Error Logs
```bash
docker-compose logs portfolio | grep error
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs portfolio

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port Already in Use
```bash
# Find process using port 80
lsof -i :80

# Or change the port in docker-compose.yml
```

### Build Failures
```bash
# Clean Docker system
docker system prune -a

# Remove specific image
docker rmi my_portfolio
```

## Performance Optimization

The Dockerfile uses:
- **Multi-stage builds** - Smaller final image
- **Alpine Linux** - Minimal base image
- **Nginx** - High-performance web server
- **Static assets** - Pre-built at compile time
- **Gzip compression** - Reduced bandwidth
- **Browser caching** - Faster repeat visits

## Security

Nginx configuration includes:
- X-Frame-Options header (clickjacking protection)
- X-Content-Type-Options header (MIME sniffing protection)
- X-XSS-Protection header
- Referrer-Policy header

## Updating the Application

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Build and Push Docker Image
  run: |
    docker build -t portfolio:latest .
    docker push portfolio:latest
```

### Auto-deploy
Use watchtower for automatic updates:
```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  my_portfolio
```
