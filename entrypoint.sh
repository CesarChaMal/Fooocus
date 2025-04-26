#!/bin/bash
# entrypoint.sh - Container entrypoint for Fooocus

set -e

# Set working directories
cd /content

# Prepare symbolic links
if [ ! -L /content/app ]; then
    ln -s /content/Fooocus /content/app
fi

if [ ! -L /content/app/models ]; then
    mkdir -p /content/data/models
    ln -s /content/data/models /content/app/models
fi

if [ ! -L /content/app/outputs ]; then
    mkdir -p /content/data/outputs
    ln -s /content/data/outputs /content/app/outputs
fi

# Launch the main script
cd /content/Fooocus
python entry_with_update.py --share --always-high-vram
