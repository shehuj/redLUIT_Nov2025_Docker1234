#!/bin/bash
# Foundational Level: Cleanup Jenkins Resources
# This script removes all Jenkins containers and volumes

set -e

echo "========================================="
echo "FOUNDATIONAL: Cleanup Jenkins Resources"
echo "========================================="
echo ""

# Stop and remove containers
echo "Step 1: Stopping and removing Jenkins containers..."
docker stop jenkins_foundational 2>/dev/null || true
docker stop jenkins_foundational_new 2>/dev/null || true
docker rm jenkins_foundational 2>/dev/null || true
docker rm jenkins_foundational_new 2>/dev/null || true
echo "✓ Containers removed"
echo ""

# Remove volume
echo "Step 2: Removing Jenkins data volume..."
docker volume rm jenkins_data_foundational 2>/dev/null || true
echo "✓ Volume removed"
echo ""

# Display remaining resources
echo "Checking for any remaining Jenkins resources..."
echo ""
echo "Containers:"
docker ps -a | grep jenkins || echo "  No Jenkins containers found"
echo ""
echo "Volumes:"
docker volume ls | grep jenkins || echo "  No Jenkins volumes found"
echo ""
echo "✓ Cleanup complete!"
echo "========================================="
