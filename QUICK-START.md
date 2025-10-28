# Quick Start Guide - SSL Setup

## 🚀 Easy SSL Setup (Recommended)

Run this single command on your VPS:

```bash
./setup-letsencrypt.sh
```

This script will:
1. ✅ Update Nginx configuration with your domain
2. ✅ Start Docker containers
3. ✅ Obtain Let's Encrypt SSL certificate
4. ✅ Configure auto-renewal
5. ✅ Enable HTTPS redirect

**Prerequisites:**
- Domain DNS pointing to your VPS IP
- Port 80 and 443 open in firewall
- Docker and Docker Compose installed

---

## 🔧 Manual Setup (Alternative)

### Step 1: Update Domain in nginx.conf

Replace `localhost` with your domain on line 41:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

### Step 2: Deploy Without SSL First

```bash
docker-compose up -d
```

Verify HTTP works: `http://yourdomain.com`

### Step 3: Stop Container

```bash
docker-compose down
```

### Step 4: Get SSL Certificate

```bash
sudo certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your@email.com \
  --agree-tos
```

### Step 5: Copy Certificates

```bash
mkdir -p ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem
```

### Step 6: Enable HTTPS Redirect

Edit `nginx.conf`, uncomment lines 51-53:

```nginx
location / {
    return 301 https://$server_name$request_uri;
}
```

And comment out lines 55-94 (HTTP content serving).

### Step 7: Restart Container

```bash
docker-compose up -d
```

### Step 8: Test SSL

```bash
curl -I https://yourdomain.com
```

---

## 🔥 Troubleshooting

### Certificate Request Failed

**Error:** "Some challenges have failed"

**Solutions:**

1. **Check DNS:**
```bash
dig yourdomain.com
# Should show your VPS IP
```

2. **Check Port 80:**
```bash
# Make sure nothing is using port 80
sudo lsof -i :80

# If docker is running, stop it
docker-compose down
```

3. **Check Firewall:**
```bash
# UFW
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# iptables
sudo iptables -L -n | grep 80
```

4. **Verify Domain Resolves:**
```bash
curl -I http://yourdomain.com
# Should reach your server
```

5. **Check Certbot Logs:**
```bash
sudo cat /var/log/letsencrypt/letsencrypt.log
```

### Common Issues

**Issue 1: Port 80 Already in Use**
```bash
# Find what's using it
sudo lsof -i :80

# Stop docker
docker-compose down

# Then retry certbot
```

**Issue 2: Firewall Blocking**
```bash
# Check if port is accessible from outside
telnet yourdomain.com 80

# If not, configure firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

**Issue 3: DNS Not Propagated**
```bash
# Check DNS
nslookup yourdomain.com

# Wait 5-10 minutes and retry
```

**Issue 4: Rate Limited**
Let's Encrypt has rate limits. If you hit them:
- Wait 1 hour for failed validations
- Wait 1 week for duplicate certificates
- Use staging for testing: `certbot --staging`

---

## 🔄 Certificate Renewal

Auto-renewal is configured by the script. Manual renewal:

```bash
# Test renewal (dry run)
sudo certbot renew --dry-run

# Force renewal
sudo certbot renew --force-renewal

# After renewal, copy certs and restart
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
docker-compose restart
```

---

## ✅ Verification

After setup, verify everything works:

```bash
# 1. HTTP redirects to HTTPS
curl -I http://yourdomain.com
# Should show: 301 Moved Permanently

# 2. HTTPS works
curl -I https://yourdomain.com
# Should show: 200 OK

# 3. Certificate is valid
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null

# 4. Check SSL grade
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com
```

---

## 📞 Need Help?

1. Check logs: `docker-compose logs -f`
2. Check Certbot logs: `sudo cat /var/log/letsencrypt/letsencrypt.log`
3. Verify domain resolves: `dig yourdomain.com`
4. Check ports: `sudo lsof -i :80` and `sudo lsof -i :443`
5. Test connection: `curl -v http://yourdomain.com`

---

## 🎯 Quick Commands Reference

```bash
# Deploy
./setup-letsencrypt.sh

# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Rebuild
docker-compose build --no-cache

# Check certificate expiry
openssl x509 -in ssl/cert.pem -noout -dates

# Manual renewal
./renew-ssl.sh
```
