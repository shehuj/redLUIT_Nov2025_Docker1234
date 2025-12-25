#!/bin/bash
# Foundational Level: Verify Jenkins Data Persistence
# This script stops the current container and launches a new one with the same volume

set -e

echo "========================================="
echo "FOUNDATIONAL: Verifying Data Persistence"
echo "========================================="
echo ""

# Check if original container exists
if ! docker ps -a | grep -q jenkins_foundational; then
    echo "Error: jenkins_foundational container not found!"
    echo "Please run ./01-setup-jenkins.sh first"
    exit 1
fi

# Step 1: Stop and remove the original container
echo "Step 1: Stopping and removing the original Jenkins container..."
docker stop jenkins_foundational
docker rm jenkins_foundational
echo "✓ Original container removed"
echo ""

# Step 2: Launch new container with same volume
echo "Step 2: Launching new Jenkins container with existing volume..."
docker run -d \
  --name jenkins_foundational_new \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data_foundational:/var/jenkins_home \
  jenkins/jenkins:lts

echo "✓ New Jenkins container 'jenkins_foundational_new' started"
echo ""

# Wait for Jenkins to start
echo "Waiting for Jenkins to initialize (30 seconds)..."
sleep 30
echo ""

# Step 3: Retrieve admin password (should be the same)
echo "Step 3: Retrieving Admin password from new container..."
ADMIN_PASSWORD=$(docker exec jenkins_foundational_new cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not found - already configured!")
echo "Admin Password: $ADMIN_PASSWORD"
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
echo "========================================="
