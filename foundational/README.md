# Foundational Level: Jenkins CLI Deployment

This level demonstrates basic Jenkins deployment using Docker CLI commands.

## Prerequisites

- Docker installed and running
- Ports 8080 and 50000 available

## Steps

### 1. Setup Jenkins

Run the setup script:

```bash
chmod +x 01-setup-jenkins.sh
./01-setup-jenkins.sh
```

This script will:
- Pull the Jenkins LTS image from Docker Hub
- Create a Docker volume `jenkins_data_foundational` for data persistence
- Run Jenkins container with volume mounted and ports mapped (8080, 50000)
- Retrieve and display the initial admin password

### 2. Initial Configuration

1. Open http://localhost:8080 in your browser
2. Enter the admin password displayed by the script
3. Install recommended plugins
4. Create a new admin user (remember the credentials!)

### 3. Verify Data Persistence

Run the verification script:

```bash
chmod +x 02-verify-persistence.sh
./02-verify-persistence.sh
```

This script will:
- Stop and remove the original Jenkins container
- Launch a new container using the same volume
- Verify data persistence by checking if you can login with your created user

### 4. Cleanup

To remove all Jenkins resources:

```bash
chmod +x 03-cleanup.sh
./03-cleanup.sh
```

This removes:
- All Jenkins containers
- Jenkins data volume
- All associated resources

## Key Concepts Demonstrated

1. **Docker Image Management**: Pulling images from Docker Hub
2. **Volume Creation**: Creating named volumes for data persistence
3. **Container Management**: Running containers with proper port mapping
4. **Data Persistence**: Verifying that data survives container recreation
5. **Resource Cleanup**: Properly removing containers and volumes

## Commands Reference

```bash
# Pull Jenkins LTS image
docker pull jenkins/jenkins:lts

# Create volume
docker volume create jenkins_data_foundational

# Run Jenkins container
docker run -d \
  --name jenkins_foundational \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data_foundational:/var/jenkins_home \
  jenkins/jenkins:lts

# Get admin password
docker exec jenkins_foundational cat /var/jenkins_home/secrets/initialAdminPassword

# Check container status
docker ps -a | grep jenkins

# View container logs
docker logs jenkins_foundational

# Stop container
docker stop jenkins_foundational

# Remove container
docker rm jenkins_foundational

# Remove volume
docker volume rm jenkins_data_foundational
```

## Troubleshooting

### Port Already in Use

If port 8080 is already in use, modify the port mapping:

```bash
docker run -d \
  --name jenkins_foundational \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_data_foundational:/var/jenkins_home \
  jenkins/jenkins:lts
```

Then access Jenkins at http://localhost:8081

### Container Won't Start

Check container logs:

```bash
docker logs jenkins_foundational
```

### Volume Issues

List all volumes:

```bash
docker volume ls
```

Inspect a specific volume:

```bash
docker volume inspect jenkins_data_foundational
```
