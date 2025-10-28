#!/bin/bash

# Let's Encrypt SSL Setup for Docker + Nginx
# This script sets up SSL with Let's Encrypt for your portfolio

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔒 Let's Encrypt SSL Setup${NC}\n"

# Check if running on VPS
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: docker-compose.yml not found${NC}"
    echo "Please run this script from the portfolio directory"
    exit 1
fi

# Get domain and email
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter your email address: " EMAIL

echo -e "\n${YELLOW}📋 Configuration:${NC}"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
read -p "Is this correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Step 1: Update nginx.conf with domain
echo -e "\n${YELLOW}📝 Step 1: Updating nginx.conf with your domain...${NC}"
sed -i.bak "s/server_name localhost;/server_name $DOMAIN www.$DOMAIN;/" nginx.conf
echo -e "${GREEN}✓${NC} Domain configured"

# Step 2: Build and start containers
echo -e "\n${YELLOW}🐳 Step 2: Starting Docker containers...${NC}"
docker-compose down 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d
sleep 5

# Check if container is running
if ! docker ps | grep -q my_portfolio; then
    echo -e "${RED}❌ Error: Container failed to start${NC}"
    docker-compose logs --tail=20
    exit 1
fi
echo -e "${GREEN}✓${NC} Container is running"

# Step 3: Create directory for ACME challenge inside container
echo -e "\n${YELLOW}📁 Step 3: Preparing ACME challenge directory...${NC}"
docker exec my_portfolio mkdir -p /usr/share/nginx/html/.well-known/acme-challenge
docker exec my_portfolio chmod -R 755 /usr/share/nginx/html/.well-known
echo -e "${GREEN}✓${NC} Directory created"

# Step 4: Install certbot if not present
echo -e "\n${YELLOW}🔧 Step 4: Checking Certbot installation...${NC}"
if ! command -v certbot &> /dev/null; then
    echo "Certbot not found. Installing..."

    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y certbot
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        sudo yum install -y certbot
    else
        echo -e "${RED}❌ Unsupported OS. Please install certbot manually${NC}"
        echo "Visit: https://certbot.eff.org/"
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} Certbot is installed"

# Step 5: Obtain certificate using certbot standalone
echo -e "\n${YELLOW}🔐 Step 5: Obtaining SSL certificate...${NC}"
echo "This will temporarily stop your container to obtain the certificate"
read -p "Continue? (y/n): " continue_cert

if [ "$continue_cert" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Stop container
echo "Stopping container..."
docker-compose down

# Obtain certificate
echo "Obtaining certificate from Let's Encrypt..."
sudo certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --preferred-challenges http

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Certificate request failed${NC}"
    echo "Please check:"
    echo "  1. Domain DNS points to this server"
    echo "  2. Port 80 is accessible from internet"
    echo "  3. No firewall blocking port 80"
    exit 1
fi

# Step 6: Copy certificates
echo -e "\n${YELLOW}📋 Step 6: Copying certificates...${NC}"
mkdir -p ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem
echo -e "${GREEN}✓${NC} Certificates copied"

# Step 7: Enable HTTPS redirect
echo -e "\n${YELLOW}🔀 Step 7: Enabling HTTPS redirect...${NC}"
sed -i 's|# location / {|location / {|' nginx.conf
sed -i 's|#     return 301 https://\$server_name\$request_uri;|    return 301 https://\$server_name\$request_uri;|' nginx.conf
sed -i 's|# }|}|' nginx.conf

# Comment out HTTP content serving (lines 55-94)
sed -i '55,94s/^/# /' nginx.conf

echo -e "${GREEN}✓${NC} HTTPS redirect enabled"

# Step 8: Restart containers
echo -e "\n${YELLOW}🔄 Step 8: Restarting containers with SSL...${NC}"
docker-compose up -d
sleep 5

# Step 9: Verify SSL
echo -e "\n${YELLOW}✅ Step 9: Verifying SSL...${NC}"
if docker exec my_portfolio curl -k -s https://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} SSL is working inside container"
else
    echo -e "${YELLOW}⚠${NC}  SSL check failed (this might be normal)"
fi

# Step 10: Setup auto-renewal
echo -e "\n${YELLOW}🔄 Step 10: Setting up auto-renewal...${NC}"

# Create renewal script
cat > renew-ssl.sh << EOF
#!/bin/bash
# Stop container for renewal
cd $(pwd)
docker-compose down

# Renew certificate
certbot renew --quiet

# Copy renewed certificates
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

# Restart container
docker-compose up -d
EOF

chmod +x renew-ssl.sh

# Add to crontab (runs at 2 AM daily)
CRON_CMD="0 2 * * * $(pwd)/renew-ssl.sh >> $(pwd)/ssl-renewal.log 2>&1"
(crontab -l 2>/dev/null | grep -v "renew-ssl.sh"; echo "$CRON_CMD") | crontab -

echo -e "${GREEN}✓${NC} Auto-renewal configured (runs daily at 2 AM)"

# Final status
echo -e "\n${GREEN}✅ SSL Setup Complete!${NC}"
echo -e "\n${GREEN}🎉 Your portfolio is now accessible at:${NC}"
echo -e "  HTTP:  ${YELLOW}http://$DOMAIN${NC} (redirects to HTTPS)"
echo -e "  HTTPS: ${GREEN}https://$DOMAIN${NC}"
echo -e "  HTTPS: ${GREEN}https://www.$DOMAIN${NC}"

echo -e "\n${YELLOW}📋 Important Notes:${NC}"
echo "  1. Certificates auto-renew daily at 2 AM"
echo "  2. Renewal logs: $(pwd)/ssl-renewal.log"
echo "  3. Certificate expires in 90 days"
echo "  4. Test renewal: sudo certbot renew --dry-run"

echo -e "\n${YELLOW}🔍 Test your SSL:${NC}"
echo "  curl -I https://$DOMAIN"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"

echo -e "\n${YELLOW}📚 Useful Commands:${NC}"
echo "  View logs:        docker-compose logs -f"
echo "  Restart:          docker-compose restart"
echo "  Manual renewal:   ./renew-ssl.sh"
echo "  Check cert:       openssl x509 -in ssl/cert.pem -text -noout"
