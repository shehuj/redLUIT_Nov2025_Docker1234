# Complex Level: Custom Jenkins Docker Image

This level demonstrates building a custom Jenkins Docker image with pre-installed tools, plugins, and configuration.

## Prerequisites

- Docker installed and running
- Ports 8080 and 50000 available
- Basic understanding of Dockerfile syntax
- 4GB+ available disk space

## Architecture

### Custom Dockerfile Components

1. **Base Image**: `jenkins/jenkins:lts`
2. **System Tools**:
   - Git, Vim, Curl, Wget
   - Python3 and pip
   - Docker CLI
   - Docker Compose
   - kubectl (Kubernetes)
   - Terraform
   - Ansible

3. **Jenkins Plugins**: Pre-installed from `plugins.txt`
   - Git and GitHub integration
   - Pipeline and workflow tools
   - Docker and Kubernetes plugins
   - Code quality tools (SonarQube, JUnit)
   - Credentials and security plugins
   - Notification plugins (Email, Slack)

4. **Configuration**:
   - Configuration as Code (CasC) via `jenkins.yaml`
   - Pre-configured admin user
   - System message and settings
   - Sample pipeline job

## Quick Start

### Option 1: All-in-One Deployment

```bash
chmod +x *.sh
./05-deploy-all.sh
```

### Option 2: Step-by-Step Deployment

```bash
# Make scripts executable
chmod +x *.sh

# Step 1: Build custom image
./01-build-image.sh

# Step 2: Create volume
./02-create-volume.sh

# Step 3: Run container
./03-run-container.sh

# Step 4: Get admin password
./04-get-password.sh
```

## Scripts Overview

### 01-build-image.sh
Builds the custom Jenkins Docker image from the Dockerfile.

**What it does**:
- Validates Dockerfile exists
- Builds image with custom tools and plugins
- Tags image as `jenkins-custom-complex:1.0` and `:latest`
- Displays build progress and final image details

**Estimated time**: 5-10 minutes (first build)

### 02-create-volume.sh
Creates a named Docker volume for Jenkins data persistence.

**What it does**:
- Creates `jenkins_data_complex` volume
- Displays volume details and mount point
- Handles existing volume conflicts

### 03-run-container.sh
Runs the custom Jenkins container with proper configuration.

**What it does**:
- Validates image and volume exist
- Runs container with volume mounted
- Exposes ports 8080 and 50000
- Mounts Docker socket for Docker-in-Docker
- Sets restart policy
- Waits for initialization

### 04-get-password.sh
Retrieves the Jenkins admin password.

**What it does**:
- Checks container is running
- Retrieves initial admin password
- Shows CasC credentials if applicable
- Displays recent container logs

### 05-deploy-all.sh
All-in-one script that runs steps 1-4 sequentially.

**What it does**:
- Executes all deployment steps
- Provides progress updates
- Displays final access information

### 06-cleanup-all.sh
Complete cleanup of all Jenkins resources.

**What it does**:
- Stops and removes container
- Removes data volume (DATA LOSS!)
- Removes custom images
- Optionally prunes dangling images
- Verifies cleanup completion

## Configuration Files

### Dockerfile
Defines the custom Jenkins image build process.

Key sections:
```dockerfile
# System dependencies
RUN apt-get update && apt-get install -y \
    git vim curl wget python3 docker.io

# Install tools
RUN install-docker-compose
RUN install-kubectl
RUN install-terraform
RUN pip3 install ansible

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Apply Configuration as Code
COPY jenkins.yaml /var/jenkins_home/casc_jenkins.yaml
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_jenkins.yaml
```

### plugins.txt
List of Jenkins plugins to pre-install.

Format: `plugin-id:version` or `plugin-id` (for latest)

Example:
```text
git:latest
docker-workflow:latest
kubernetes:latest
configuration-as-code:latest
```

### jenkins.yaml
Configuration as Code (CasC) file for Jenkins setup.

Features:
- System message
- Security realm (local users)
- Authorization strategy
- Admin user creation
- Tool configurations (Git, Maven, JDK)
- Sample pipeline job

Default credentials (if CasC enabled):
- **Username**: admin
- **Password**: admin123

## Usage Examples

### Access Jenkins

```bash
# Open in browser
open http://localhost:8080

# Or manually open:
# http://localhost:8080
```

### View Container Logs

```bash
docker logs -f jenkins_complex
```

### Execute Commands in Container

```bash
# Access bash shell
docker exec -it jenkins_complex bash

# Run specific command
docker exec jenkins_complex java -version
docker exec jenkins_complex docker --version
docker exec jenkins_complex kubectl version --client
```

### Backup Jenkins Data

```bash
# Create backup of volume
docker run --rm \
  -v jenkins_data_complex:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/jenkins-backup.tar.gz -C /source .
```

### Restore Jenkins Data

```bash
# Restore from backup
docker run --rm \
  -v jenkins_data_complex:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/jenkins-backup.tar.gz -C /target
```

## Customization

### Modify Dockerfile

Edit `Dockerfile` to add/remove tools:

```dockerfile
# Add new tool
RUN apt-get update && apt-get install -y your-tool

# Or use pip
RUN pip3 install your-python-package
```

Then rebuild:
```bash
./01-build-image.sh
```

### Add More Plugins

Edit `plugins.txt`:

```text
# Add new plugin
your-plugin:latest
another-plugin:1.2.3
```

Rebuild image to include new plugins.

### Modify CasC Configuration

Edit `jenkins.yaml` to change:
- Admin credentials
- System settings
- Tool versions
- Pre-configured jobs

Changes take effect on container restart.

## Troubleshooting

### Build Fails

```bash
# Check Docker is running
docker info

# Review build logs
docker build --no-cache --progress=plain .

# Check disk space
df -h
```

### Container Won't Start

```bash
# Check container logs
docker logs jenkins_complex

# Inspect container
docker inspect jenkins_complex

# Check port conflicts
lsof -i :8080
```

### Plugins Not Installing

```bash
# Verify plugins.txt format
cat plugins.txt

# Check plugin IDs at:
# https://plugins.jenkins.io/

# Build with verbose output
docker build --progress=plain . 2>&1 | grep plugin
```

### CasC Not Loading

```bash
# Check if CasC plugin is installed
docker exec jenkins_complex ls /var/jenkins_home/plugins | grep configuration-as-code

# Verify YAML syntax
docker exec jenkins_complex cat /var/jenkins_home/casc_jenkins.yaml

# Check CasC logs
docker logs jenkins_complex | grep -i casc
```

## Advanced Topics

### Multi-Stage Build

Create more efficient images:

```dockerfile
# Build stage
FROM jenkins/jenkins:lts as builder
RUN download-large-files

# Runtime stage
FROM jenkins/jenkins:lts
COPY --from=builder /files /destination
```

### Docker-in-Docker

The container has Docker access via socket mount:

```bash
# Run Docker commands from Jenkins
docker exec jenkins_complex docker ps
docker exec jenkins_complex docker version
```

### Health Checks

Monitor container health:

```bash
# Check health status
docker inspect jenkins_complex --format='{{.State.Health.Status}}'

# View health logs
docker inspect jenkins_complex --format='{{json .State.Health}}' | jq
```

## Security Considerations

1. **Change Default Passwords**: Update `jenkins.yaml` admin password
2. **Use Secrets**: Don't hardcode credentials in Dockerfile
3. **Limit Docker Socket**: Consider security implications of Docker access
4. **Update Regularly**: Rebuild with latest base image and plugins
5. **Network Isolation**: Use Docker networks for service communication
6. **Scan Images**: Use `docker scan jenkins-custom-complex:latest`

## Performance Optimization

### Reduce Image Size

```dockerfile
# Combine RUN commands
RUN apt-get update && apt-get install -y \
    package1 package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use multi-stage builds
# Use .dockerignore file
```

### Speed Up Builds

```bash
# Use build cache
docker build .

# Parallel plugin installation
# Order Dockerfile for cache efficiency
```

## CI/CD Integration

This custom image can be used in CI/CD pipelines:

```yaml
# GitHub Actions
- name: Build custom Jenkins
  run: ./01-build-image.sh

- name: Run tests
  run: docker run jenkins-custom-complex:latest jenkins --version
```

## Requirements Met

This complex level demonstrates:

✅ Custom Dockerfile creation
✅ Image building from Dockerfile
✅ Volume creation for data persistence
✅ Port mapping (8080, 50000)
✅ Admin password retrieval
✅ User creation and login
✅ Container and volume removal
✅ Image cleanup

Plus additional features:
- Pre-installed tools (Docker, Kubernetes, Terraform, Ansible)
- Pre-installed Jenkins plugins
- Configuration as Code (CasC)
- Health checks and monitoring
- Comprehensive management scripts
