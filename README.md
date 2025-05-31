# xFasterTransformer Benchmark Toolkit

A comprehensive toolset for setting up and benchmarking [xFasterTransformer](https://github.com/zhiyisun/xFasterTransformer) with multiple model support.

## Overview

This repository provides a Docker-based environment for:
1. Setting up xFasterTransformer in an isolated container
2. Installing xFasterTransformer dependencies and building from source
3. Downloading, converting, and benchmarking various transformer models

## Scripts Overview

- `setup_docker.sh` - Setup Docker environment and build container
- `setup_environment.sh` - Setup xFasterTransformer environment (inside container)
- `prepare_models.sh` - Download and convert models to xFasterTransformer format
- `benchmark_models.sh` - Run benchmarks on prepared models
- `demo_models.sh` - Run interactive demos with prepared models

## Quick Start

### 1. Setup Docker Environment

First, setup the Docker environment:

```bash
./setup_docker.sh
```

This will:
- Clone xFasterTransformer repository (if needed)
- Build Docker image with all dependencies
- Start container with workspace mounted

### 2. Setup xFasterTransformer (Inside Container)

Once inside the Docker container, setup the xFasterTransformer environment:

```bash
./setup_environment.sh
```

This script will:
- Install Python dependencies from requirements.txt
- Build and install xFasterTransformer from source
- Install required Python libraries (transformers, huggingface-hub)

### 3. Prepare Models

After setup is complete, prepare the models you want to use:

```bash
# Prepare Qwen3-0.6B (default model)
HF_TOKEN=your_token_here ./prepare_models.sh

# Prepare specific model
HF_TOKEN=your_token_here MODEL=qwen3-0.6b ./prepare_models.sh
HF_TOKEN=your_token_here MODEL=deepseek-r1-qwen-7b ./prepare_models.sh
```

### 4. Run Benchmarks

Once models are prepared, you can run benchmarks (no HF_TOKEN needed):

```bash
# Benchmark default model (qwen3-0.6b)
./benchmark_models.sh

# Benchmark specific model
MODEL=deepseek-r1-qwen-7b ./benchmark_models.sh
```

### 5. Run Interactive Demos

You can also run interactive demos with the prepared models:

```bash
# Demo with default model (qwen3-0.6b)
./demo_models.sh

# Demo with specific model
MODEL=deepseek-r1-qwen-7b ./demo_models.sh
```

## Available Models

- `qwen3-0.6b` - Qwen/Qwen3-0.6B (default)
- `deepseek-r1-qwen-7b` - deepseek-ai/DeepSeek-R1-Distill-Qwen-7B

## Environment Variables

### For Model Preparation (`prepare_models.sh`)
- `HF_TOKEN` (Required) - Hugging Face authentication token
- `MODEL` (Optional) - Model to prepare (default: qwen3-0.6b)

### For Benchmarks and Demos (`benchmark_models.sh`, `demo_models.sh`)
- `MODEL` (Optional) - Model to use (default: qwen3-0.6b)
- **No HF_TOKEN required** (uses pre-prepared models from `prepare_models.sh`)

## Directory Structure

```
./models/$MODEL      - Original downloaded model
./models/$MODEL-xft  - Converted XFT model  
/data/               - Final model location for benchmarking
xFasterTransformer/  - xFasterTransformer source code
```

## Requirements

- Docker and Docker Compose
- Git
- Hugging Face account and token (for model downloads)
- Sufficient disk space for models and Docker images

## Features

- **Containerized Environment**: Isolated Docker environment with all dependencies
- **Modular Scripts**: Separate preparation, benchmarking, and demo workflows
- **Model Caching**: Models are cached locally to avoid re-downloading
- **Smart Skipping**: Automatically skips steps if files already exist
- **Multiple Models**: Easy switching between different transformer models
- **Interactive Demos**: Run demos with prepared models without needing tokens
- **Preserved Artifacts**: Converted models are preserved for reuse
- **Clean Development**: No system-wide installation required

## Troubleshooting

### Common Issues

1. **Container not starting**: Ensure Docker is running and you have proper permissions
2. **xFasterTransformer not found**: Run `./setup_environment.sh` inside the container first
3. **Permission denied**: Ensure scripts are executable with `chmod +x *.sh`
4. **Model not found**: Run `./prepare_models.sh` first to download and convert models
5. **Model download fails**: Check your `HF_TOKEN` is valid during preparation
6. **Out of space**: Ensure sufficient disk space for Docker images and models

### Re-setup Environment

If you need to rebuild xFasterTransformer inside the container:

```bash
./setup_environment.sh
```

### Rebuild Docker Environment

To rebuild the Docker image with latest changes:

```bash
# Stop and remove existing container
docker stop xft-benchmark 2>/dev/null || true
docker rm xft-benchmark 2>/dev/null || true

# Rebuild and start fresh
./setup_docker.sh
```

### Clean Start

To start fresh, remove cached models and prepare again:

```bash
# Remove cached models
rm -rf ./models/
sudo rm -rf /data/

# Prepare models again
HF_TOKEN=your_token ./prepare_models.sh
```

## Workflow Overview

The toolkit follows a clear separation of concerns:

1. **Setup Phase** (one-time):
   ```bash
   ./setup_docker.sh          # Setup Docker environment
   ./setup_environment.sh     # Setup xFasterTransformer (inside container)
   ```

2. **Model Preparation** (when you need new models):
   ```bash
   HF_TOKEN=token ./prepare_models.sh  # Download and convert models
   ```

3. **Usage Phase** (multiple times, no tokens needed):
   ```bash
   ./benchmark_models.sh      # Run benchmarks
   ./demo_models.sh          # Run interactive demos
   ```

## Contributing

Feel free to contribute by:
- Adding support for new models
- Improving setup scripts
- Enhancing documentation
- Reporting issues

## License

This project follows the same license as xFasterTransformer.