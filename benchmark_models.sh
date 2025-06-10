#!/bin/bash
#
# benchmark_models.sh: Benchmark runner for xFasterTransformer models
#
# This script runs benchmarks on pre-prepared xFasterTransformer models.
# It validates the environment and executes benchmark tests.
#
# Prerequisites: 
#   - xFasterTransformer environment setup (run ./setup_environment.sh)
#   - Pre-prepared models (run ./prepare_models.sh first)
#
# Usage: 
#   ./benchmark_models.sh                    # Benchmark default model
#   MODEL=deepseek-r1-qwen-7b ./benchmark_models.sh
#
# Environment Variables:
#   MODEL - Model to benchmark (default: qwen3-0.6b)
#           Available: qwen3-0.6b, deepseek-r1-qwen-7b

# Configuration
set -e  # Exit on any error
set -x  # Print commands for debugging

# Default values
DEFAULT_MODEL="qwen3-0.6b"
AVAILABLE_MODELS=("qwen3-0.6b" "deepseek-r1-qwen-7b")

# ============================================================================
# Helper Functions
# ============================================================================

print_usage() {
    echo "Usage: [MODEL=model_name] $0"
    echo ""
    echo "Available models:"
    for model in "${AVAILABLE_MODELS[@]}"; do
        echo "  - $model"
    done
    echo ""
    echo "Examples:"
    echo "  $0                              # Benchmark default model"
    echo "  MODEL=deepseek-r1-qwen-7b $0    # Benchmark specific model"
}

validate_dependencies() {
    if ! python -c "import xfastertransformer" 2>/dev/null; then
        echo "Error: xFasterTransformer not installed or accessible"
        echo "Please run ./setup_environment.sh first"
        exit 1
    fi
}

get_model_config() {
    local model="$1"
    case "$model" in
        "qwen3-0.6b")
            echo "/data/Qwen3-0.6B-xft" "qwen3-0.6b" "../examples/model_config/qwen3-0.6b"
            ;;
        "deepseek-r1-qwen-7b")
            echo "/data/Qwen2.5-7B-Instruct-xft" "qwen2-7b" "../examples/model_config/qwen2-7b"
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================================
# Main Script
# ============================================================================

# Validate dependencies
validate_dependencies

# Set model with default fallback
MODEL="${MODEL:-$DEFAULT_MODEL}"

# Validate model selection
if ! printf '%s\n' "${AVAILABLE_MODELS[@]}" | grep -q "^$MODEL$"; then
    echo "Error: Invalid model '$MODEL'"
    echo ""
    print_usage
    exit 1
fi

# Get model configuration
config_result=$(get_model_config "$MODEL")
if [ $? -ne 0 ]; then
    echo "Error: Failed to get configuration for model '$MODEL'"
    exit 1
fi

# Parse configuration
read -r DATA_DIR BENCHMARK_MODEL BENCHMARK_CONFIG <<< "$config_result"

echo "Selected model: $MODEL"
echo "Model path: $DATA_DIR"
echo "Benchmark config: $BENCHMARK_CONFIG"

# ============================================================================
# Verify Model Availability
# ============================================================================

if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Model not found at $DATA_DIR"
    echo ""
    echo "Please run the preparation script first:"
    echo "  HF_TOKEN=your_token MODEL=$MODEL ./prepare_models.sh"
    exit 1
fi

# ============================================================================
# Run Benchmarks
# ============================================================================

echo ""
echo "🚀 Starting benchmarks for $MODEL"
echo ""

# Navigate to benchmark directory and execute
cd xFasterTransformer/benchmark
./run_benchmark.sh -m "$BENCHMARK_MODEL" -mp "$BENCHMARK_CONFIG" -tp ../examples/model_config/$BENCHMARK_MODEL -in 32 -out 32 -i 1

echo ""
echo "✅ Benchmark completed successfully!"
