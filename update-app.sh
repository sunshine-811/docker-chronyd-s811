#!/bin/sh

APP_NAME="ntp-server"

# This script updates the Chrony application on an S811 board.
# It uses the Docker image "chronyd-s811" to run the application.
# Ensure the script is run with root privileges
# or with sudo to have permission to run Docker containers.
# Usage: ./update-app.sh
# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi
# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi
# Check if Docker daemon is running
if ! systemctl is-active --quiet docker; then
    echo "Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Pull the latest Docker image for Chrony
echo "Pulling the latest Docker image for Chrony on S811..."
git fetch
# Stash any local changes
git stash
git merge '@{u}'
# Pop the stashed changes
git stash pop

# Check if the pull was successful
if [ $? -eq 0 ]; then
    echo "Docker image 'chronyd-s811' updated successfully."
else
    echo "Failed to update Docker image."
    exit 1
fi

# Build the Docker image
echo "Building Docker image for Chrony on S811..."
docker build -t chronyd-s811 .

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Docker image 'chronyd-s811' built successfully."
else
    echo "Failed to build Docker image."
    exit 1
fi

docker pull chronyd-s811:latest
# Check if the pull was successful
if [ $? -eq 0 ]; then
    echo "Docker image 'chronyd-s811' updated successfully."
else
    echo "Failed to update Docker image."
    exit 1
fi

# Stop and remove the existing Docker container
docker compose down

# Check if the stop and remove were successful
if [ $? -eq 0 ]; then
    echo "Docker container stopped and removed successfully."
else
    echo "Failed to stop and remove Docker container."
    exit 1
fi

# Start the Docker container with the updated image
echo "Starting Docker container with the updated image..."
docker compose up -d

# Check if the start was successful
if [ $? -eq 0 ]; then
    echo "Docker container started successfully."
else
    echo "Failed to start Docker container."
    exit 1
fi

# Check the status of the Docker container
echo "Checking the status of the Docker container..."
docker ps -a

# Check if the container is running
if [ $? -eq 0 ]; then
    echo "Docker container is running successfully."
else
    echo "Failed to start Docker container."
    exit 1
fi

# Check the logs of the Docker container
echo "Checking the logs of the Docker container..."
docker compose logs --tail=100

# Check the status of the Chrony service inside the container
echo "Checking the status of the Chrony service inside the container..."
docker exec -it ${APP_NAME} chronyc tracking