#!/bin/bash
#
# demo_models.sh: Interactive demo runner for xFasterTransformer models
#
# This script runs an interactive demo using pre-converted xFasterTransformer models.
# It validates the environment, checks for model availability, and launches the demo.
#
# Prerequisites: 
#   - xFasterTransformer environment setup (run ./setup_environment.sh)
#   - Pre-prepared models (run ./prepare_models.sh first)
#
# Usage: 
#   ./demo_models.sh                    # Uses default model (qwen3-0.6b)
#   MODEL=deepseek-r1-qwen-7b ./demo_models.sh
#
# Environment Variables:
#   MODEL - Model to demo (default: qwen3-0.6b)
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
    echo "  $0                              # Use default model"
    echo "  MODEL=deepseek-r1-qwen-7b $0    # Use specific model"
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
            echo "/data/Qwen3-0.6B-xft" "../model_config/qwen3-0.6b"
            ;;
        "deepseek-r1-qwen-7b")
            echo "/data/Qwen2.5-7B-Instruct-xft" "../model_config/qwen2-7b"
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
read -r DATA_DIR DEMO_CONFIG <<< "$config_result"

echo "Selected model: $MODEL"
echo "Model path: $DATA_DIR"
echo "Config path: $DEMO_CONFIG"

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
# Launch Demo
# ============================================================================

echo ""
echo "🚀 Starting interactive demo for $MODEL"
echo ""
echo "Demo Instructions:"
echo "  • Enter your prompts when asked"
echo "  • Press Enter with empty input to use default prompt"
echo "  • Use Ctrl+C to exit"
echo ""

# Navigate to demo directory and run
cd xFasterTransformer/examples/pytorch

echo "Launching demo..."
python3 demo.py -t "$DEMO_CONFIG" -m "$DATA_DIR"

echo ""
echo "✅ Demo completed successfully!"
