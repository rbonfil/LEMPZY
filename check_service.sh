#!/bin/bash 
# Function to check and restart a service
# Created and Developed by a Lazy Sysadmin
# X@rbonfil  info@rbonfil.me
#
# Configure Cron
# chmod +x check_service.sh
# crontab -e
# * * * * * /home/check_service.sh   (Every Minute)
# */5 * * * * /home/check_service.sh (Every 5 Minutes)

check_and_restart() {
    local service=$1
    local status=$(service $service status)
    
    if echo "$status" | grep -q "active (running)"; then
        echo "The $service service is running correctly."
    else
        echo "The $service service is not active. Attempting to restart..."
        service $service stop
        service $service start
        local new_status=$(service $service status)
        if echo "$new_status" | grep -q "active (running)"; then
            echo "The $service service was restarted successfully."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - The $service service was restarted successfully." >> check_service.log
        else
            echo "Failed to restart the $service service."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to restart the $service service." >> check_service.log
        fi
    fi
}

# List of Services to Check; You Can Add More
services=("php7.3-fpm" "php7.4-fpm" "php8.2-fpm" "php8.3-fpm" "mysql" "nginx")

# Iterate over each service in the list and call the check_and_restart function
for service in "${services[@]}"; do
    check_and_restart $service
done
