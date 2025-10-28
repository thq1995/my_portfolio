#!/bin/bash

# SSL Setup Script for Portfolio
# This script helps you set up SSL certificates for your portfolio

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔒 SSL Certificate Setup${NC}\n"

# Create ssl directory if it doesn't exist
mkdir -p ssl

echo "Choose an option:"
echo "1) Generate self-signed certificate (for testing)"
echo "2) Use Let's Encrypt with Certbot (for production)"
echo "3) Use existing certificate files"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo -e "\n${YELLOW}Generating self-signed certificate...${NC}"
        read -p "Enter your domain name (e.g., localhost or yourdomain.com): " domain

        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem \
            -out ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=$domain"

        echo -e "${GREEN}✓${NC} Self-signed certificate generated!"
        echo -e "${YELLOW}⚠️  Warning: Self-signed certificates will show browser warnings${NC}"
        ;;

    2)
        echo -e "\n${YELLOW}Setting up Let's Encrypt certificate...${NC}"
        read -p "Enter your domain name: " domain
        read -p "Enter your email: " email

        echo -e "\n${YELLOW}Installing Certbot...${NC}"
        if command -v certbot &> /dev/null; then
            echo -e "${GREEN}✓${NC} Certbot already installed"
        else
            echo "Please install certbot first:"
            echo "  Ubuntu/Debian: sudo apt install certbot"
            echo "  macOS: brew install certbot"
            exit 1
        fi

        echo -e "\n${YELLOW}Obtaining certificate...${NC}"
        echo "Make sure your domain points to this server and port 80 is accessible"
        read -p "Press Enter to continue..."

        sudo certbot certonly --standalone \
            -d $domain \
            --email $email \
            --agree-tos \
            --no-eff-email

        # Copy certificates to ssl directory
        sudo cp /etc/letsencrypt/live/$domain/fullchain.pem ssl/cert.pem
        sudo cp /etc/letsencrypt/live/$domain/privkey.pem ssl/key.pem
        sudo chown $USER:$USER ssl/*.pem

        echo -e "${GREEN}✓${NC} Let's Encrypt certificate installed!"

        # Create renewal cron job
        echo -e "\n${YELLOW}Setting up auto-renewal...${NC}"
        (crontab -l 2>/dev/null; echo "0 0 * * * certbot renew --quiet && cp /etc/letsencrypt/live/$domain/fullchain.pem $PWD/ssl/cert.pem && cp /etc/letsencrypt/live/$domain/privkey.pem $PWD/ssl/key.pem && docker-compose restart") | crontab -
        echo -e "${GREEN}✓${NC} Auto-renewal configured (daily check)"
        ;;

    3)
        echo -e "\n${YELLOW}Using existing certificates...${NC}"
        echo "Please place your certificate files in the ssl/ directory:"
        echo "  - ssl/cert.pem (certificate file)"
        echo "  - ssl/key.pem (private key file)"
        read -p "Press Enter when files are ready..."

        if [ -f "ssl/cert.pem" ] && [ -f "ssl/key.pem" ]; then
            echo -e "${GREEN}✓${NC} Certificate files found!"
        else
            echo -e "${RED}❌ Certificate files not found${NC}"
            exit 1
        fi
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Set correct permissions
chmod 644 ssl/cert.pem
chmod 600 ssl/key.pem

echo -e "\n${GREEN}✅ SSL setup complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Update ${YELLOW}nginx.conf${NC} server_name with your domain"
echo -e "2. Uncomment the HTTPS redirect in nginx.conf (line 44)"
echo -e "3. Run ${YELLOW}docker-compose down && docker-compose up -d${NC} to apply changes"
echo -e "\nYour portfolio will be available at:"
echo -e "  HTTP:  ${GREEN}http://yourdomain.com${NC}"
echo -e "  HTTPS: ${GREEN}https://yourdomain.com${NC}"
