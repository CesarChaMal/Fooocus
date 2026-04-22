#!/bin/bash

set -e

# Variables
ENV_NAME="fooocus"

# Setup Conda
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
python entry_with_update.py --share --always-high-vram --port 7860
