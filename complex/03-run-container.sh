#!/bin/bash
# Complex Level: Run Custom Jenkins Container
# This script runs the custom Jenkins container with proper configuration

set -e

echo "========================================="
echo "COMPLEX: Running Custom Jenkins Container"
echo "========================================="
echo ""

# Configuration
IMAGE_NAME="jenkins-custom-complex:latest"
CONTAINER_NAME="jenkins_complex"
VOLUME_NAME="jenkins_data_complex"
HTTP_PORT="8080"
AGENT_PORT="50000"

# Check if image exists
if ! docker images | grep -q "jenkins-custom-complex"; then
    echo "Error: Custom Jenkins image not found!"
    echo "Please run ./01-build-image.sh first"
    exit 1
fi

# Check if volume exists
if ! docker volume inspect "$VOLUME_NAME" &> /dev/null; then
    echo "Error: Volume '$VOLUME_NAME' not found!"
    echo "Please run ./02-create-volume.sh first"
    exit 1
fi

# Check if container already exists
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "Warning: Container '$CONTAINER_NAME' already exists!"
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping and removing existing container..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        echo "✓ Container removed"
    else
        echo "Starting existing container..."
        docker start "$CONTAINER_NAME"
        exit 0
    fi
fi

# Run the container
echo "Starting Jenkins container..."
echo "Container: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME"
echo "Volume: $VOLUME_NAME"
echo "Ports: $HTTP_PORT:8080, $AGENT_PORT:50000"
echo ""

docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$HTTP_PORT:8080" \
    -p "$AGENT_PORT:50000" \
    -v "$VOLUME_NAME:/var/jenkins_home" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --restart unless-stopped \
    "$IMAGE_NAME"

echo "✓ Container started successfully"
echo ""

# Wait for Jenkins to initialize
echo "Waiting for Jenkins to initialize (60 seconds)..."
sleep 60
echo ""

# Check container status
echo "Container Status:"
docker ps | grep "$CONTAINER_NAME"
echo ""

# Check container health
echo "Health Status:"
docker inspect "$CONTAINER_NAME" --format='{{.State.Health.Status}}' 2>/dev/null || echo "No health check configured"
echo ""

echo "========================================="
echo "Jenkins is Running!"
echo "========================================="
echo "URL: http://localhost:$HTTP_PORT"
echo ""
echo "Next Steps:"
echo "1. Get admin password: ./04-get-password.sh"
echo "2. View logs:          docker logs -f $CONTAINER_NAME"
echo "3. Access shell:       docker exec -it $CONTAINER_NAME bash"
echo ""
echo "Container Management:"
echo "  Stop:    docker stop $CONTAINER_NAME"
echo "  Start:   docker start $CONTAINER_NAME"
echo "  Restart: docker restart $CONTAINER_NAME"
echo "  Remove:  docker rm -f $CONTAINER_NAME"
echo "========================================="
