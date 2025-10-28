# SSL/HTTPS Setup Guide

This guide will help you set up SSL/HTTPS for your portfolio.

## Quick Start

```bash
# Run the interactive SSL setup script
./setup-ssl.sh
```

## Manual Setup Options

### Option 1: Self-Signed Certificate (Testing Only)

Good for local development and testing. Browsers will show security warnings.

```bash
# Create ssl directory
mkdir -p ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Set permissions
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem
```

### Option 2: Let's Encrypt (Production - Recommended)

Free, automated SSL certificates trusted by all browsers.

#### Prerequisites
- Domain name pointing to your VPS
- Port 80 and 443 accessible
- Certbot installed

#### Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install certbot
```

**macOS:**
```bash
brew install certbot
```

#### Obtain Certificate

**Method A: Standalone (when nginx is not running)**
```bash
# Stop docker container first
docker-compose down

# Get certificate
sudo certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your@email.com \
  --agree-tos

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem
```

**Method B: Webroot (when nginx is running)**
```bash
# Create directory for verification
mkdir -p /var/www/html/.well-known/acme-challenge

# Get certificate
sudo certbot certonly --webroot \
  -w /var/www/html \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your@email.com \
  --agree-tos

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
```

#### Auto-Renewal Setup

Let's Encrypt certificates expire every 90 days. Set up auto-renewal:

```bash
# Create renewal script
cat > renew-ssl.sh << 'EOF'
#!/bin/bash
certbot renew --quiet
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /path/to/portfolio/ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /path/to/portfolio/ssl/key.pem
cd /path/to/portfolio && docker-compose restart
EOF

chmod +x renew-ssl.sh

# Add to crontab (runs daily at midnight)
(crontab -l 2>/dev/null; echo "0 0 * * * /path/to/renew-ssl.sh") | crontab -
```

Or use certbot's built-in renewal:
```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab
sudo crontab -e
# Add this line:
0 0 * * * certbot renew --quiet && systemctl reload nginx
```

### Option 3: Custom Certificate

If you have purchased an SSL certificate:

```bash
# Create ssl directory
mkdir -p ssl

# Copy your files
cp /path/to/your/certificate.crt ssl/cert.pem
cp /path/to/your/private.key ssl/key.pem

# Set permissions
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem
```

## Nginx Configuration

### 1. Update Server Name

Edit `nginx.conf` and replace `localhost` with your domain:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

### 2. Enable HTTPS Redirect

Uncomment line 44 in `nginx.conf`:

```nginx
# HTTP Server
server {
    listen 80;
    server_name yourdomain.com;

    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}
```

### 3. Enable HSTS (Optional but Recommended)

Uncomment line 109 in `nginx.conf`:

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## Deployment

### With Docker Compose

```bash
# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d
```

### Verify SSL

```bash
# Check certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check SSL grade (external)
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com
```

## Troubleshooting

### Certificate Not Found Error

```
nginx: [emerg] cannot load certificate "/etc/nginx/ssl/cert.pem"
```

**Solution:**
```bash
# Check if files exist
ls -la ssl/

# Ensure permissions
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

# Restart container
docker-compose restart
```

### Port 443 Already in Use

```bash
# Find what's using port 443
sudo lsof -i :443

# Or
sudo netstat -tlnp | grep :443

# Stop the service or change docker-compose port mapping
```

### Browser Security Warning

**Self-signed certificates:**
- Click "Advanced" → "Proceed to site" (testing only)
- Not recommended for production

**Let's Encrypt issues:**
```bash
# Check certificate validity
openssl x509 -in ssl/cert.pem -text -noout

# Verify chain
openssl verify -CAfile ssl/cert.pem ssl/cert.pem
```

### Certificate Renewal Failed

```bash
# Check certbot logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Manual renewal
sudo certbot renew --force-renewal

# Update copied certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
docker-compose restart
```

## Security Best Practices

### 1. Certificate Permissions
```bash
# Certificate (public) - readable
chmod 644 ssl/cert.pem

# Private key - readable by owner only
chmod 600 ssl/key.pem
```

### 2. Keep Certificates Updated
- Let's Encrypt: Auto-renew every 60 days (expires at 90)
- Commercial: Renew before expiration

### 3. Use Strong Ciphers
The nginx.conf includes modern, secure cipher suites:
- TLS 1.2 and 1.3 only
- Forward secrecy enabled
- Weak ciphers disabled

### 4. Enable HSTS
Force HTTPS for 1 year after first visit:
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### 5. Regular Security Scans
- SSL Labs: https://www.ssllabs.com/ssltest/
- Mozilla Observatory: https://observatory.mozilla.org/

## Testing

### Local Testing
```bash
# Test with curl
curl -I https://localhost

# Test redirect
curl -I http://localhost
```

### Production Testing
```bash
# Test SSL
curl -I https://yourdomain.com

# Check certificate expiry
echo | openssl s_client -servername yourdomain.com -connect yourdomain.com:443 2>/dev/null | openssl x509 -noout -dates
```

## Firewall Configuration

Make sure ports are open:

```bash
# UFW (Ubuntu)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

# iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables-save
```

## Resources

- Let's Encrypt: https://letsencrypt.org/
- Certbot: https://certbot.eff.org/
- SSL Labs: https://www.ssllabs.com/ssltest/
- Mozilla SSL Config: https://ssl-config.mozilla.org/
