#!/bin/bash

LOG_FILE="/var/log/devopsfetch.log"

# Create the log file if it doesn't exist and set permissions
if [ ! -f "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"
    sudo chmod 666 "$LOG_FILE"
fi

# Function to display help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -p, --port                List all active ports and services"
    echo "  -p <port_number>          Detailed information about a specific port"
    echo "  -d, --docker              List all Docker images and containers"
    echo "  -d <container_name>       Detailed information about a specific container"
    echo "  -n, --nginx               Display all Nginx domains and their ports"
    echo "  -n <domain>               Detailed configuration information for a specific domain"
    echo "  -u, --users               List all users and their last login times"
    echo "  -u <username>             Detailed information about a specific user"
    echo "  -t, --time <start> <end>  Display activities within a specified time range"
    echo "  --install                 Install dependencies and set up the service"
    echo "  -h, --help                Show this help message"
}

# Function to log messages
log_message() {
    echo "$1" | sudo tee -a "$LOG_FILE"
}

# Functions to handle each option
list_ports() {
    log_message "Listing all active ports and services..."
    netstat -tuln | sudo tee -a "$LOG_FILE"
}

list_docker() {
    log_message "Listing all Docker images..."
    docker images | sudo tee -a "$LOG_FILE"
    log_message "Listing all Docker containers..."
    docker ps -a | sudo tee -a "$LOG_FILE"
}

list_users() {
    log_message "Listing all users and their last login times..."
    lastlog | sudo tee -a "$LOG_FILE"
}

# Function to handle detailed port information
port_details() {
    local port=$1
    log_message "Detailed information about port $port..."
    netstat -tuln | grep ":$port" | sudo tee -a "$LOG_FILE"
}

# Function to handle detailed Docker container information
container_details() {
    local container_name=$1
    log_message "Detailed information about container $container_name..."
    docker inspect "$container_name" | sudo tee -a "$LOG_FILE"
}

# Function to handle detailed Nginx domain information
domain_details() {
    local domain=$1
    log_message "Detailed configuration for domain $domain..."
    grep -r "server_name $domain" /etc/nginx/sites-enabled/ | sudo tee -a "$LOG_FILE"
}

# Function to handle detailed user information
user_details() {
    local username=$1
    log_message "Detailed information about user $username..."
    lastlog | grep "$username" | sudo tee -a "$LOG_FILE"
}

# Function to filter activities by time range
filter_by_time_range() {
    local start_time=$1
    local end_time=$2
    log_message "Activities from $start_time to $end_time..."
    journalctl --since="$start_time" --until="$end_time" | sudo tee -a "$LOG_FILE"
}

# Main script logic
if [ "$1" == "--install" ]; then
    log_message "Installing dependencies and setting up the service..."
    sudo apt-get update
    sudo apt-get install -y net-tools nginx docker.io
    sudo systemctl enable docker
    sudo systemctl start docker

    sudo tee /etc/systemd/system/devopsfetch.service > /dev/null <<EOL
[Unit]
Description=devopsfetch - DevOps System Information Retrieval Tool
After=network.target

[Service]
ExecStart=/home/hayzedak/HNG5/devopsfetch.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

    sudo systemctl daemon-reload
    sudo systemctl enable devopsfetch
    sudo systemctl start devopsfetch
elif [ "$1" == "-p" ] || [ "$1" == "--port" ]; then
    if [ -n "$2" ]; then
        port_details "$2"
    else
        list_ports
    fi
elif [ "$1" == "-d" ] || [ "$1" == "--docker" ]; then
    if [ -n "$2" ]; then
        container_details "$2"
    else
        list_docker
    fi
elif [ "$1" == "-n" ] || [ "$1" == "--nginx" ]; then
    if [ -n "$2" ]; then
        domain_details "$2"
    else
        grep -r "server_name" /etc/nginx/sites-enabled/ | sudo tee -a "$LOG_FILE"
    fi
elif [ "$1" == "-u" ] || [ "$1" == "--users" ]; then
    if [ -n "$2" ]; then
        user_details "$2"
    else
        list_users
    fi
elif [ "$1" == "-t" ] || [ "$1" == "--time" ]; then
    if [ -n "$2" ] && [ -n "$3" ]; then
        filter_by_time_range "$2" "$3"
    else
        echo "Please provide both start and end times in the format 'YYYY-MM-DD HH:MM:SS'"
    fi
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
else
    echo "Unknown option: $1"
    show_help
fi

