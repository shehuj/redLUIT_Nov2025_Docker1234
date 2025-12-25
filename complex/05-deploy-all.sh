#!/bin/bash
# Complex Level: All-in-One Deployment Script
# This script builds, creates volume, and runs the Jenkins container

set -e

echo "========================================="
echo "COMPLEX: Complete Jenkins Deployment"
echo "========================================="
echo ""
echo "This script will:"
echo "1. Build custom Jenkins image"
echo "2. Create data volume"
echo "3. Run Jenkins container"
echo "4. Retrieve admin password"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 1: Build image
echo "=== Step 1/4: Building Image ==="
./01-build-image.sh
echo ""

# Step 2: Create volume
echo "=== Step 2/4: Creating Volume ==="
./02-create-volume.sh
echo ""

# Step 3: Run container
echo "=== Step 3/4: Running Container ==="
./03-run-container.sh
echo ""

# Step 4: Get password
echo "=== Step 4/4: Retrieving Password ==="
./04-get-password.sh
echo ""

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Jenkins is now running at: http://localhost:8080"
echo ""
echo "Useful Commands:"
echo "  View logs:      docker logs -f jenkins_complex"
echo "  Stop Jenkins:   docker stop jenkins_complex"
echo "  Start Jenkins:  docker start jenkins_complex"
echo "  Cleanup:        ./06-cleanup-all.sh"
echo "========================================="
