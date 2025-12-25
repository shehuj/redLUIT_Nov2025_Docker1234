#!/bin/bash
# Advanced Level: Verify Jenkins Data Persistence with Docker Compose
# This script recreates the container to verify volume persistence

set -e

echo "========================================="
echo "ADVANCED: Verifying Data Persistence"
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

# Step 1: Stop and remove containers
echo "Step 1: Stopping and removing Jenkins container..."
$COMPOSE_CMD down
echo "✓ Container removed (volume preserved)"
echo ""

# Verify volume still exists
echo "Verifying volume exists..."
if docker volume ls | grep -q jenkins_data_advanced; then
    echo "✓ Volume 'jenkins_data_advanced' still exists"
else
    echo "✗ Volume not found!"
    exit 1
fi
echo ""

# Step 2: Recreate Jenkins container
echo "Step 2: Recreating Jenkins container with existing volume..."
$COMPOSE_CMD up -d
echo "✓ Container recreated"
echo ""

# Wait for Jenkins to start
echo "Waiting for Jenkins to initialize (45 seconds)..."
sleep 45
echo ""

# Step 3: Check admin password
echo "Step 3: Checking configuration..."
ADMIN_PASSWORD=$(docker exec jenkins_advanced cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Already configured - password not found")
echo "Admin Password Status: $ADMIN_PASSWORD"
echo ""

# Display service status
echo "Service Status:"
$COMPOSE_CMD ps
echo ""

echo "========================================="
echo "Data Persistence Verification:"
echo "========================================="
echo "URL: http://localhost:8080"
echo ""
echo "If data persisted correctly:"
echo "1. You should NOT see the setup wizard"
echo "2. You can login with the user you created earlier"
echo "3. All configurations and jobs should still exist"
echo ""
echo "✓ Verification complete!"
echo ""
echo "View logs: $COMPOSE_CMD logs -f"
echo "========================================="
