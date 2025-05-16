#!/bin/bash
#
# benchmark_xft.sh: Benchmark script for xFasterTransformer with Qwen3-0.6B model
#
# This script:
# 1. Sets up xFasterTransformer environment
# 2. Downloads the Qwen3-0.6B model from Hugging Face
# 3. Converts the model to xFasterTransformer format
# 4. Runs benchmarks on the converted model
#
# Usage: HF_TOKEN=your_token_here ./benchmark_xft.sh

# Exit on any error
set -e

# Print commands for debugging
set -x

# Check if HF_TOKEN is provided
if [ -z "$HF_TOKEN" ]; then
  echo "Error: HF_TOKEN environment variable is not set"
  echo "Please run the script with: HF_TOKEN=your_token_here ./benchmark_xft.sh"
  exit 1
fi

# Step 1: Navigate to xFasterTransformer directory and set up environment
echo "Setting up xFasterTransformer environment..."
cd xFasterTransformer

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

# Build and install xFasterTransformer
echo "Building xFasterTransformer..."
python setup.py build
python setup.py install

# Install or upgrade transformers library
echo "Installing/upgrading transformers library..."
pip3 install --upgrade transformers

# Step 2: Download the Qwen3-0.6B model from Hugging Face
echo "Downloading Qwen3-0.6B model from Hugging Face..."
huggingface-cli download Qwen/Qwen3-0.6B --local-dir qwen --exclude "original/*" --token $HF_TOKEN

# Step 3: Convert the model to xFasterTransformer format
echo "Converting model to xFasterTransformer format..."
python -c 'import xfastertransformer as xft; xft.LlamaConvert().convert("./qwen","./qwen-xft")'
sudo mkdir /data
sudo mv ./qwen-xft /data/Qwen3-0.6B-xft

# Step 4: Run benchmarks on the converted model
echo "Running benchmarks on the converted model..."
cd benchmark
./run_benchmark.sh -m qwen3-0.6b -mp ../examples/model_config/qwen3-0.6b

echo "Benchmark completed successfully!"