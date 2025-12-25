#!/bin/bash
# Advanced Level: Cleanup Jenkins Resources
# This script removes all Jenkins containers, volumes, and networks

set -e

echo "========================================="
echo "ADVANCED: Cleanup Jenkins Resources"
echo "========================================="
echo ""

# Determine compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Using: $COMPOSE_CMD"
echo ""

# Step 1: Stop and remove containers, networks
echo "Step 1: Stopping containers and removing networks..."
$COMPOSE_CMD down
echo "✓ Containers and networks removed"
echo ""

# Step 2: Remove volumes
echo "Step 2: Removing Jenkins volumes..."
$COMPOSE_CMD down -v
echo "✓ Volumes removed"
echo ""

# Step 3: Verify cleanup
echo "Step 3: Verifying cleanup..."
echo ""
echo "Containers:"
docker ps -a | grep jenkins_advanced || echo "  ✓ No Jenkins containers found"
echo ""
echo "Volumes:"
docker volume ls | grep jenkins_data_advanced || echo "  ✓ No Jenkins volumes found"
echo ""
echo "Networks:"
docker network ls | grep advanced_jenkins_network || echo "  ✓ No Jenkins networks found"
echo ""

echo "✓ Cleanup complete!"
echo "========================================="
