#!/bin/bash
# Complex Level: Complete Cleanup Script
# This script removes container, volume, and custom image

set -e

echo "========================================="
echo "COMPLEX: Complete Cleanup"
echo "========================================="
echo ""
echo "WARNING: This will remove:"
echo "  - Jenkins container (jenkins_complex)"
echo "  - Jenkins volume (jenkins_data_complex)"
echo "  - Custom image (jenkins-custom-complex)"
echo "  - ALL JENKINS DATA WILL BE LOST!"
echo ""
read -p "Are you sure you want to continue? (type 'yes'): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# Step 1: Stop and remove container
echo "Step 1: Removing container..."
if docker ps -a | grep -q jenkins_complex; then
    docker stop jenkins_complex 2>/dev/null || true
    docker rm jenkins_complex 2>/dev/null || true
    echo "✓ Container removed"
else
    echo "  No container found"
fi
echo ""

# Step 2: Remove volume
echo "Step 2: Removing volume..."
if docker volume ls | grep -q jenkins_data_complex; then
    docker volume rm jenkins_data_complex 2>/dev/null || true
    echo "✓ Volume removed"
else
    echo "  No volume found"
fi
echo ""

# Step 3: Remove custom image
echo "Step 3: Removing custom image..."
if docker images | grep -q jenkins-custom-complex; then
    docker rmi jenkins-custom-complex:1.0 2>/dev/null || true
    docker rmi jenkins-custom-complex:latest 2>/dev/null || true
    echo "✓ Image removed"
else
    echo "  No custom image found"
fi
echo ""

# Step 4: Verify cleanup
echo "Step 4: Verifying & cleaning up leftover Jenkins resources..."
echo ""

echo "----------------------------------------"
echo "Checking for leftover Jenkins containers..."

# Remove containers matching pattern (if any)
containers=$(docker ps -a --filter "name=jenkins_complex" -q)
if [ -n "$containers" ]; then
  echo "Removing containers:"
  docker ps -a --filter "name=jenkins_complex"
  docker rm -f $containers
else
  echo "  ✓ No Jenkins containers found"
fi

echo ""
echo "Checking for leftover Jenkins volumes..."

# Remove volumes matching pattern (if any)
volumes=$(docker volume ls --format "{{.Name}}" | grep jenkins_data_complex || true)
if [ -n "$volumes" ]; then
  echo "Removing volumes:"
  echo "$volumes"
  docker volume rm $volumes
else
  echo "  ✓ No Jenkins volumes found"
fi

echo ""
echo "Checking for leftover Jenkins images..."

# Remove images matching pattern (if any)
images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep jenkins-custom-complex || true)
if [ -n "$images" ]; then
  echo "Removing images:"
  echo "$images"
  docker rmi -f $images
else
  echo "  ✓ No Jenkins images found"
fi

echo "----------------------------------------"
echo ""
echo "Cleanup complete!"

# Always succeed
exit 0

echo ""
echo "========================================="
echo "Cleanup Complete!"
echo "========================================="
echo ""
echo "To redeploy Jenkins:"
echo "  ./05-deploy-all.sh"
echo ""
echo "Or step by step:"
echo "  ./01-build-image.sh"
echo "  ./02-create-volume.sh"
echo "  ./03-run-container.sh"
echo "  ./04-get-password.sh"
echo "========================================="
