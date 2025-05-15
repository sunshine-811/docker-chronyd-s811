#!/bin/bash

# This script builds a Docker image for Chrony on an S811 board.
# It uses the Dockerfile located in the current directory.
# The image is tagged as "chronyd-s811".
# Ensure the script is run with root privileges
# or with sudo to have permission to build Docker images.
# Usage: ./build.sh
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
