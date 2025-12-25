# Advanced Level: Jenkins Docker Compose Deployment

This level demonstrates Jenkins deployment using Docker Compose for easier management and configuration.

## Prerequisites

- Docker installed and running
- Docker Compose installed (or Docker with Compose V2)
- Ports 8080 and 50000 available

## Architecture

The Docker Compose setup includes:

- **Service**: Jenkins LTS container
- **Volume**: Named volume for data persistence
- **Network**: Isolated bridge network for Jenkins
- **Health Check**: Automated health monitoring
- **Restart Policy**: Automatic restart on failure

## Steps

### 1. Setup Jenkins

Run the setup script:

```bash
chmod +x 01-setup-jenkins.sh
./01-setup-jenkins.sh
```

This script will:
- Pull the Jenkins LTS image
- Start Jenkins using Docker Compose
- Create volume and network automatically
- Display the initial admin password

### 2. Initial Configuration

1. Open http://localhost:8080 in your browser
2. Enter the admin password displayed by the script
3. Install recommended plugins
4. Create a new admin user

### 3. Verify Data Persistence

Run the verification script:

```bash
chmod +x 02-verify-persistence.sh
./02-verify-persistence.sh
```

This script will:
- Stop and remove the Jenkins container (preserving the volume)
- Recreate the container using Docker Compose
- Verify you can still login with your created user

### 4. Cleanup

To remove all resources:

```bash
chmod +x 03-cleanup.sh
./03-cleanup.sh
```

## Docker Compose Commands

```bash
# Start services
docker compose up -d

# Stop services (keeps volumes)
docker compose down

# Stop services and remove volumes
docker compose down -v

# View logs
docker compose logs -f

# Check service status
docker compose ps

# Restart services
docker compose restart

# Execute command in container
docker compose exec jenkins bash
```

## Configuration

### docker-compose.yml Features

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins_advanced
    ports:
      - "8080:8080"      # Web UI
      - "50000:50000"    # Agent communication
    volumes:
      - jenkins_data_advanced:/var/jenkins_home  # Data persistence
      - /var/run/docker.sock:/var/run/docker.sock  # Docker-in-Docker
    environment:
      - JENKINS_OPTS=--prefix=/jenkins
      - JAVA_OPTS=-Djava.awt.headless=true
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/login || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
```

### Health Check

The health check monitors Jenkins availability:
- **Test**: Curl request to login page
- **Interval**: Check every 30 seconds
- **Timeout**: 10 seconds per check
- **Retries**: 5 attempts before marking unhealthy
- **Start Period**: 60 seconds grace period

## Advantages Over CLI Approach

1. **Configuration as Code**: All settings in docker-compose.yml
2. **Easier Management**: Single command to start/stop all services
3. **Environment Variables**: Centralized configuration
4. **Service Dependencies**: Automatic ordering and linking
5. **Network Isolation**: Automatic network creation
6. **Reproducibility**: Same setup on any machine
7. **Scalability**: Easy to add related services (agents, databases)

## Troubleshooting

### Port Conflicts

Change ports in docker-compose.yml:

```yaml
ports:
  - "8081:8080"  # Use port 8081 instead
  - "50001:50000"
```

### View Container Logs

```bash
docker compose logs -f jenkins
```

### Check Health Status

```bash
docker compose ps
docker inspect jenkins_advanced | grep -A 10 Health
```

### Reset Everything

```bash
docker compose down -v
docker compose up -d
```

## Adding Additional Services

Example: Add a Jenkins agent

```yaml
services:
  jenkins:
    # ... existing config ...

  jenkins-agent:
    image: jenkins/ssh-agent:latest
    container_name: jenkins_agent
    environment:
      - JENKINS_AGENT_SSH_PUBKEY=your-public-key
    networks:
      - jenkins_network
```

## Best Practices

1. **Version Control**: Commit docker-compose.yml to git
2. **Environment Files**: Use .env for sensitive data
3. **Volume Backups**: Regularly backup jenkins_data_advanced
4. **Resource Limits**: Add memory/CPU limits in production
5. **Security**: Use secrets management for credentials
6. **Monitoring**: Integrate with monitoring tools
