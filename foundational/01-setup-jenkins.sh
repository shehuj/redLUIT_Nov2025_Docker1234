#!/bin/bash
# Foundational Level: Jenkins Setup using CLI Commands
# This script demonstrates the basic Jenkins deployment workflow

set -e

echo "========================================="
echo "FOUNDATIONAL: Jenkins CLI Deployment"
echo "========================================="
echo ""

# Step 1: Pull Jenkins LTS image from Docker Hub
echo "Step 1: Pulling Jenkins LTS image from Docker Hub..."
docker pull jenkins/jenkins:lts
echo "✓ Jenkins LTS image pulled successfully"
echo ""

# Step 2: Create Docker volume for Jenkins data persistence
echo "Step 2: Creating Docker volume for Jenkins data..."
docker volume create jenkins_data_foundational
echo "✓ Volume 'jenkins_data_foundational' created"
echo ""

# Step 3: Run Jenkins container with volume and port mapping
echo "Step 3: Running Jenkins container..."
docker run -d \
  --name jenkins_foundational \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data_foundational:/var/jenkins_home \
  jenkins/jenkins:lts

echo "✓ Jenkins container 'jenkins_foundational' started"
echo ""

# Wait for Jenkins to start
echo "Waiting for Jenkins to initialize (30 seconds)..."
sleep 30
echo ""

# Step 4: Retrieve Admin password
echo "Step 4: Retrieving Jenkins Admin password..."
ADMIN_PASSWORD=$(docker exec jenkins_foundational cat /var/jenkins_home/secrets/initialAdminPassword)
echo "========================================="
echo "Jenkins Admin Password:"
echo "$ADMIN_PASSWORD"
echo "========================================="
echo ""

# Display access information
echo "========================================="
echo "Jenkins Access Information:"
echo "========================================="
echo "URL: http://localhost:8080"
echo "Admin Password: $ADMIN_PASSWORD"
echo ""
echo "Next Steps:"
echo "1. Open http://localhost:8080 in your browser"
echo "2. Use the password above to login"
echo "3. Install recommended plugins"
echo "4. Create a new admin user"
echo ""
echo "After creating a user, run: ./02-verify-persistence.sh"
echo "========================================="
