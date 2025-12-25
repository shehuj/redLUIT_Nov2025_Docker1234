#!/bin/bash
# Complex Level: Retrieve Jenkins Admin Password
# This script retrieves the initial admin password from the container

set -e

echo "========================================="
echo "COMPLEX: Retrieving Jenkins Admin Password"
echo "========================================="
echo ""

# Configuration
CONTAINER_NAME="jenkins_complex"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: Container '$CONTAINER_NAME' is not running!"
    echo "Please run ./03-run-container.sh first"
    exit 1
fi

# Retrieve admin password
echo "Retrieving admin password from container..."
echo ""

ADMIN_PASSWORD=$(docker exec "$CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")

if [ -z "$ADMIN_PASSWORD" ]; then
    echo "========================================="
    echo "Initial password not found!"
    echo "========================================="
    echo ""
    echo "This usually means one of the following:"
    echo "1. Jenkins is already configured"
    echo "2. Setup wizard has been completed"
    echo "3. Configuration as Code (CasC) is active"
    echo ""
    echo "If using CasC, default credentials are:"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
    echo "You can also check the container logs:"
    echo "  docker logs $CONTAINER_NAME"
else
    echo "========================================="
    echo "Jenkins Admin Password"
    echo "========================================="
    echo ""
    echo "$ADMIN_PASSWORD"
    echo ""
    echo "========================================="
    echo ""
    echo "Access Jenkins at: http://localhost:8080"
    echo ""
    echo "Next Steps:"
    echo "1. Open http://localhost:8080 in your browser"
    echo "2. Enter the password above"
    echo "3. Install recommended plugins"
    echo "4. Create your admin user"
fi

echo ""
echo "Container logs (last 20 lines):"
echo "----------------------------------------"
docker logs --tail 20 "$CONTAINER_NAME"
echo "========================================="
