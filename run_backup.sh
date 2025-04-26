#!/bin/bash

set -e

# Variables
REPO_URL="https://github.com/CesarChaMal/Fooocus.git"
PROJECT_DIR="Fooocus"
ENV_NAME="fooocus"

# Clone the repo if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning Fooocus repository..."
    git clone "$REPO_URL" "$PROJECT_DIR"
else
    echo "Fooocus repository already exists. Pulling latest changes..."
    cd "$PROJECT_DIR"
    git pull --rebase origin main || true
    cd ..
fi

# Enter the project directory
cd "$PROJECT_DIR"

# Setup Conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"

# Create environment if not exists
if conda env list | grep -qE "^$ENV_NAME\s"; then
    echo "Conda environment '$ENV_NAME' already exists."
else
    echo "Creating conda environment '$ENV_NAME'..."
    conda env create -f environment.yaml
fi

conda activate "$ENV_NAME"

# Install pip requirements
echo "Installing pip requirements..."
pip install -r requirements_versions.txt

# Launch Fooocus
echo "Launching Fooocus with --share and --always-high-vram..."
python entry_with_update.py --share --always-high-vram
