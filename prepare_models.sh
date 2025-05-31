#!/bin/bash
#
# prepare_models.sh: Model preparation script for xFasterTransformer
#
# This script downloads, converts, and prepares models for xFasterTransformer usage.
# It performs the following steps:
# 1. Downloads models from Hugging Face
# 2. Converts models to xFasterTransformer format
# 3. Copies converted models to /data directory
#
# Prerequisites: 
#   - xFasterTransformer environment setup (run ./setup_environment.sh)
#   - Valid Hugging Face token for model access
#
# Usage: 
#   HF_TOKEN=your_token ./prepare_models.sh                    # Prepare default model
#   HF_TOKEN=your_token MODEL=deepseek-r1-qwen-7b ./prepare_models.sh
#
# Environment Variables:
#   HF_TOKEN - Required: Hugging Face authentication token
#   MODEL    - Model to prepare (default: qwen3-0.6b)
#             Available: qwen3-0.6b, deepseek-r1-qwen-7b

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
    echo "Usage: HF_TOKEN=your_token [MODEL=model_name] $0"
    echo ""
    echo "Available models:"
    for model in "${AVAILABLE_MODELS[@]}"; do
        echo "  - $model"
    done
    echo ""
    echo "Examples:"
    echo "  HF_TOKEN=hf_xxx $0                              # Prepare default model"
    echo "  HF_TOKEN=hf_xxx MODEL=deepseek-r1-qwen-7b $0    # Prepare specific model"
}

validate_dependencies() {
    if ! python -c "import xfastertransformer" 2>/dev/null; then
        echo "Error: xFasterTransformer not installed or accessible"
        echo "Please run ./setup_environment.sh first"
        exit 1
    fi
    
    if ! command -v huggingface-cli &> /dev/null; then
        echo "Error: huggingface-cli not found"
        echo "Please install it with: pip install huggingface_hub"
        exit 1
    fi
}

get_model_config() {
    local model="$1"
    case "$model" in
        "qwen3-0.6b")
            echo "Qwen/Qwen3-0.6B" "./models/$model" "./models/$model-xft" "/data/Qwen3-0.6B-xft" "Qwen3Convert"
            ;;
        "deepseek-r1-qwen-7b")
            echo "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B" "./models/$model" "./models/$model-xft" "/data/Qwen2.5-7B-Instruct-xft" "Qwen2Convert"
            ;;
        *)
            return 1
            ;;
    esac
}

download_model() {
    local hf_model_name="$1"
    local local_dir="$2"
    
    if [ -d "$local_dir" ]; then
        echo "Model already exists at $local_dir, skipping download..."
        return 0
    fi
    
    echo "📥 Downloading model from Hugging Face: $hf_model_name"
    mkdir -p ./models
    huggingface-cli download "$hf_model_name" \
        --local-dir "$local_dir" \
        --exclude "original/*" \
        --token "$HF_TOKEN"
    echo "✅ Download completed"
}

convert_model() {
    local local_dir="$1"
    local xft_dir="$2"
    local converter_class="$3"
    
    if [ -d "$xft_dir" ]; then
        echo "Converted model already exists at $xft_dir, skipping conversion..."
        return 0
    fi
    
    echo "🔄 Converting model to xFasterTransformer format..."
    python -c "
import xfastertransformer as xft
model_converter = xft.$converter_class()
model_converter.convert('$local_dir', '$xft_dir')
"
    echo "✅ Conversion completed"
}

copy_to_data() {
    local xft_dir="$1"
    local data_dir="$2"
    
    # Create /data directory if it doesn't exist
    if [ ! -d "/data" ]; then
        echo "Creating /data directory..."
        sudo mkdir -p /data
    fi
    
    if [ -d "$data_dir" ]; then
        echo "Model already exists at $data_dir, skipping copy..."
        return 0
    fi
    
    echo "📂 Copying converted model to $data_dir..."
    sudo cp -r "$xft_dir" "$data_dir"
    echo "✅ Copy completed"
}

# ============================================================================
# Main Script
# ============================================================================

# Validate HF_TOKEN
if [ -z "$HF_TOKEN" ]; then
    echo "Error: HF_TOKEN environment variable is required"
    echo ""
    print_usage
    exit 1
fi

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
read -r HF_MODEL_NAME LOCAL_DIR XFT_DIR DATA_DIR CONVERTER_CLASS <<< "$config_result"

echo "🚀 Preparing model: $MODEL"
echo "Hugging Face model: $HF_MODEL_NAME"
echo "Local directory: $LOCAL_DIR"
echo "XFT directory: $XFT_DIR"
echo "Data directory: $DATA_DIR"
echo ""

# Execute preparation steps
download_model "$HF_MODEL_NAME" "$LOCAL_DIR"
convert_model "$LOCAL_DIR" "$XFT_DIR" "$CONVERTER_CLASS"
copy_to_data "$XFT_DIR" "$DATA_DIR"

echo ""
echo "🎉 Model preparation completed successfully!"
echo "Model '$MODEL' is ready for benchmarking and demos."
