#!/bin/bash
#
# setup.sh: Setup script for xFasterTransformer development environment
# This script:
# 1. Clones the xFasterTransformer repository if it doesn't exist
# 2. Builds a Docker image with necessary dependencies
# 3. Runs a Docker container with the current directory mounted
#

# Configuration
IMAGE_NAME="xft"

# Get the absolute path of the current directory
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------
# 1. Clone xFasterTransformer repository (if it doesn't exist)
# ----------------------------------------------------------
if [ ! -d "xFasterTransformer" ]; then
    echo "Cloning xFasterTransformer repository..."
    git clone git@github.com:zhiyisun/xFasterTransformer.git
else
    echo "xFasterTransformer directory already exists, skipping clone."
fi

# ----------------------------------------------------------
# 2. Build Docker image
# ----------------------------------------------------------
echo "Building Docker image..."
docker build -t ${IMAGE_NAME} \
    --build-arg PUID=$(id -u) \
    --build-arg PGID=$(id -g) \
    --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" \
    --build-arg ssh_pub_key="$(cat ~/.ssh/authorized_keys)" .

# ----------------------------------------------------------
# 3. Run Docker container
# ----------------------------------------------------------
echo "Starting Docker container..."
docker run -it --rm \
    --mount type=bind,source=$(pwd),target=/home/ubuntu/xft_debug \
    --cap-add=SYS_NICE \
    --security-opt seccomp=unconfined \
    ${IMAGE_NAME} /bin/bash