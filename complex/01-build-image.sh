#!/bin/bash
# Complex Level: Build Custom Jenkins Image
# This script builds a custom Jenkins Docker image from Dockerfile

set -e

echo "========================================="
echo "COMPLEX: Building Custom Jenkins Image"
echo "========================================="
echo ""

# Configuration
IMAGE_NAME="jenkins-custom-complex"
IMAGE_TAG="1.0"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Step 1: Check if Dockerfile exists
echo "Step 1: Verifying Dockerfile..."
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile not found in current directory!"
    exit 1
fi
echo "✓ Dockerfile found"
echo ""

# Step 2: Check for required files
echo "Step 2: Checking required files..."
if [ ! -f "plugins.txt" ]; then
    echo "Warning: plugins.txt not found - will skip plugin installation"
fi
if [ ! -f "jenkins.yaml" ]; then
    echo "Warning: jenkins.yaml not found - will skip CasC configuration"
fi
echo "✓ Files checked"
echo ""

# Step 3: Build the Docker image
echo "Step 3: Building Docker image '$FULL_IMAGE_NAME'..."
echo "This may take several minutes..."
echo ""

docker build \
    --tag "$FULL_IMAGE_NAME" \
    --tag "${IMAGE_NAME}:latest" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --progress=plain \
    .

echo ""
echo "✓ Image built successfully"
echo ""

# Step 4: Verify the image
echo "Step 4: Verifying image..."
docker images | grep "$IMAGE_NAME"
echo ""

# Step 5: Display image details
echo "Step 5: Image Details:"
echo "----------------------------------------"
docker inspect "$FULL_IMAGE_NAME" --format='
Image: {{.RepoTags}}
Created: {{.Created}}
Size: {{.Size}} bytes
Architecture: {{.Architecture}}
OS: {{.Os}}
'
echo "----------------------------------------"
echo ""

# Display image layers
echo "Image Layers:"
docker history "$FULL_IMAGE_NAME" --no-trunc --human | head -20
echo ""

echo "========================================="
echo "Build Complete!"
echo "========================================="
echo "Image: $FULL_IMAGE_NAME"
echo ""
echo "Next Steps:"
echo "1. Create volume:  ./02-create-volume.sh"
echo "2. Run container:  ./03-run-container.sh"
echo "3. Get password:   ./04-get-password.sh"
echo ""
echo "Or run all at once: ./05-deploy-all.sh"
echo "========================================="
