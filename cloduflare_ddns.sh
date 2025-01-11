#!/bin/bash
# --------------------------------------------------
# Bash Script for Cloudflare DDNS (IPv4 & IPv6) with cURL Integration.
# This Bash script leverages the Cloudflare API to dynamically update DNS records (A and AAAA) for both IPv4 and IPv6 addresses. 
# Designed for seamless integration with cURL, it ensures real-time updates with a TTL of 60 seconds, providing a reliable solution for maintaining up-to-date DNS entries.
# --------------------------------------------------
# Configure Cron
# chmod +x cloduflare_ddns.sh
# crontab -e
#
# * * * * * /home/cloduflare_ddns.sh   (Every Minute)
# */5 * * * * /home/cloduflare_ddns.sh (Every 5 Minutes)
# Note: Configure this script as you wish and with the time you need.
# --------------------------------------------------
# Created and Developed by a Lazy Sysadmin
# X@rbonfil  info@rbonfil.me
# --------------------------------------------------

# Configuration
ZONE_ID="xxxxxx"                      # Replace with your Cloudflare Zone ID
API_TOKEN="xxxxx"                     # Replace with your Cloudflare API Token

SUBDOMINIO="subdominio.dominio.com"   # Subdomain you want to update
RECORD_IPV4_NAME="subdominio"         # A record name (without the domain)
RECORD_IPV6_NAME="subdominio"         # A record name (without the domain)

# Get current public IP (IPv4 and IPv6)
IPV4=$(curl -s https://ipv4.icanhazip.com)
IPV6=$(curl -s https://ipv6.icanhazip.com)

# Get current A and AAAA records from Cloudflare
RECORD_A_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$SUBDOMINIO&type=A" \
    -H "Authorization: Bearer $API_TOKEN" | jq -r '.result[0].id')

RECORD_AAAA_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$SUBDOMINIO&type=AAAA" \
    -H "Authorization: Bearer $API_TOKEN" | jq -r '.result[0].id')

# Update A record (IPv4)
if [ -n "$RECORD_A_ID" ]; then
    echo "Updating A record ($SUBDOMINIO) with the IP $IPV4"
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_A_ID" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$RECORD_IPV4_NAME\",\"content\":\"$IPV4\",\"ttl\":60,\"proxied\":false}"
else
    echo "A record not found, creating a new one with the IP $IPV4"
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$RECORD_IPV4_NAME\",\"content\":\"$IPV4\",\"ttl\":60,\"proxied\":false}"
fi

# Update A record (IPv6)
if [ -n "$RECORD_AAAA_ID" ]; then
    echo "Updating AAAA record ($SUBDOMINIO) with the IP $IPV6"
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_AAAA_ID" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"AAAA\",\"name\":\"$RECORD_IPV6_NAME\",\"content\":\"$IPV6\",\"ttl\":60,\"proxied\":false}"
else
    echo "AAAA record not found, creating a new one with the IP $IPV6"
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"AAAA\",\"name\":\"$RECORD_IPV6_NAME\",\"content\":\"$IPV6\",\"ttl\":60,\"proxied\":false}"
fi

echo "DNS records update completed."