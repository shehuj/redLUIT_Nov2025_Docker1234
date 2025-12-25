#!/bin/bash
# Complex Level: Create Docker Volume for Jenkins
# This script creates a named volume for Jenkins data persistence

set -e

echo "========================================="
echo "COMPLEX: Creating Jenkins Data Volume"
echo "========================================="
echo ""

# Configuration
VOLUME_NAME="jenkins_data_complex"

# Check if volume already exists
if docker volume inspect "$VOLUME_NAME" &> /dev/null; then
    echo "Warning: Volume '$VOLUME_NAME' already exists!"
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing volume..."
        docker volume rm "$VOLUME_NAME"
        echo "✓ Volume removed"
    else
        echo "Using existing volume"
        exit 0
    fi
fi

# Create volume
echo "Creating Docker volume '$VOLUME_NAME'..."
docker volume create "$VOLUME_NAME"
echo "✓ Volume created successfully"
echo ""

# Display volume details
echo "Volume Details:"
echo "----------------------------------------"
docker volume inspect "$VOLUME_NAME" --format='
Name: {{.Name}}
Driver: {{.Driver}}
Mountpoint: {{.Mountpoint}}
Created: {{.CreatedAt}}
'
echo "----------------------------------------"
echo ""

echo "✓ Volume setup complete!"
echo ""
echo "Next Step: ./03-run-container.sh"
