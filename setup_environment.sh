#!/bin/bash
#
# setup_environment.sh: Setup xFasterTransformer development environment
#
# This script performs the following setup tasks:
# 1. Installs Python dependencies from requirements.txt
# 2. Builds and installs xFasterTransformer from source
# 3. Installs/upgrades required Python libraries
#
# Usage: ./setup_environment.sh
#
# Note: This script should be run once before using benchmark_models.sh
#       or whenever you need to rebuild xFasterTransformer
#       If using Docker, run ./setup_docker.sh first to setup the container

# Exit on any error
set -e

# Print commands for debugging
set -x

# ============================================================================
# xFasterTransformer Environment Setup
# ============================================================================

echo "Setting up xFasterTransformer environment..."

# Check if xFasterTransformer directory exists
if [ ! -d "xFasterTransformer" ]; then
  echo "Error: xFasterTransformer directory not found"
  echo "Please ensure you're running this script from the correct directory"
  exit 1
fi

# Navigate to xFasterTransformer directory
cd xFasterTransformer

# Install Python dependencies from requirements.txt
echo "Installing Python dependencies from requirements.txt..."
if [ -f "requirements.txt" ]; then
  pip3 install -r requirements.txt
else
  echo "Warning: requirements.txt not found, skipping dependency installation"
fi

# Build and install xFasterTransformer from source
echo "Building xFasterTransformer from source..."
python setup.py build

echo "Installing xFasterTransformer..."
python setup.py install

# Install or upgrade transformers library for model compatibility
echo "Installing/upgrading transformers library..."
pip3 install --upgrade transformers

# Install huggingface-hub for model downloading
echo "Installing/upgrading huggingface-hub..."
pip3 install --upgrade huggingface-hub

echo "xFasterTransformer environment setup completed successfully!"
echo ""
echo "You can now run prepare_models.sh to download models before benchmarking."
