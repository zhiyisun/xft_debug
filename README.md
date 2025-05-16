# xft_debug

A toolset for setting up and benchmarking [xFasterTransformer](https://github.com/zhiyisun/xFasterTransformer).

## Overview

This repository contains scripts for:
1. Setting up a Docker environment for xFasterTransformer development
2. Benchmarking xFasterTransformer with Qwen models

## Scripts

### setup.sh

Sets up the xFasterTransformer development environment:
- Clones the xFasterTransformer repository
- Builds a Docker image with necessary dependencies
- Runs a Docker container with the current directory mounted

### benchmark_xft.sh

Runs within the Docker container to benchmark xFasterTransformer:
- Sets up the xFasterTransformer environment
- Downloads the Qwen3-0.6B model from Hugging Face
- Converts the model to xFasterTransformer format
- Runs benchmarks on the converted model

## Requirements

- Docker
- Git
- Hugging Face account and token (for model downloads)

## Getting Started

1. Run the setup script to create the Docker environment:
   ```bash
   ./setup.sh
   ```

2. Inside the Docker container, run the benchmark script:
   ```bash
   HF_TOKEN=your_token_here ./benchmark_xft.sh
   ```