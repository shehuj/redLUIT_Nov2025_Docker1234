#!/bin/bash
# Advanced Level: Jenkins Setup using Docker Compose
# This script demonstrates Jenkins deployment with Docker Compose

set -e

echo "========================================="
echo "ADVANCED: Jenkins Docker Compose Deployment"
echo "========================================="
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose not found!"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Determine compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Using: $COMPOSE_CMD"
echo ""

# Step 1: Pull Jenkins image
echo "Step 1: Pulling Jenkins LTS image..."
docker pull jenkins/jenkins:lts
echo "✓ Image pulled successfully"
echo ""

# Step 2: Start Jenkins using Docker Compose
echo "Step 2: Starting Jenkins with Docker Compose..."
$COMPOSE_CMD up -d
echo "✓ Jenkins started"
echo ""

# Wait for Jenkins to initialize
echo "Waiting for Jenkins to initialize (45 seconds)..."
sleep 45
echo ""

# Step 3: Retrieve admin password
echo "Step 3: Retrieving Jenkins Admin password..."
ADMIN_PASSWORD=$(docker exec jenkins_advanced cat /var/jenkins_home/secrets/initialAdminPassword)
echo "========================================="
echo "Jenkins Admin Password:"
echo "$ADMIN_PASSWORD"
echo "========================================="
echo ""

# Display service status
echo "Checking service status..."
$COMPOSE_CMD ps
echo ""

# Display access information
echo "========================================="
echo "Jenkins Access Information:"
echo "========================================="
echo "URL: http://localhost:8080"
echo "Admin Password: $ADMIN_PASSWORD"
echo ""
echo "Volume: jenkins_data_advanced"
echo "Network: advanced_jenkins_network"
echo ""
echo "Next Steps:"
echo "1. Open http://localhost:8080 in your browser"
echo "2. Use the password above to login"
echo "3. Install recommended plugins"
echo "4. Create a new admin user"
echo ""
echo "Commands:"
echo "  View logs:    $COMPOSE_CMD logs -f"
echo "  Stop:         $COMPOSE_CMD stop"
echo "  Start:        $COMPOSE_CMD start"
echo "  Restart:      $COMPOSE_CMD restart"
echo ""
echo "After creating a user, run: ./02-verify-persistence.sh"
echo "========================================="
