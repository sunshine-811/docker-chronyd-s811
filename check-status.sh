#!/bin/sh

. vars

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
# Check if the Docker image exists
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "Docker image '$IMAGE_NAME' does not exist. Please build it first."
    exit 1
fi
# Check if the Docker container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Docker container '$CONTAINER_NAME' is not running. Please start it first."
    exit 1
fi
# Check if the Docker container is healthy
if ! docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" | grep -q "healthy"; then
    echo "Docker container '$CONTAINER_NAME' is not healthy. Please check the logs."
    exit 1
fi

# Check the status of the Chrony service inside the container
echo "Checking the status of the Chrony service inside the container..."
docker exec -it $CONTAINER_NAME chronyc tracking