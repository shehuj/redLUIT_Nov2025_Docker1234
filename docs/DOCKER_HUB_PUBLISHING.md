# Docker Hub Publishing Guide

This guide explains how the repository publishes Docker images to Docker Hub.

## Overview

The repository includes a unified CI/CD workflow that automatically builds and publishes all custom Docker images to Docker Hub when changes are pushed to the `main` branch.

## Published Images

### 1. Jenkins Custom (`redluit/jenkins-custom`)

**Source:** `complex/Dockerfile`

**Description:** Custom Jenkins image with pre-installed DevOps tools

**Pre-installed Tools:**
- Git, Vim, Curl
- Docker, Docker Compose
- kubectl (Kubernetes CLI)
- Terraform (IaC tool)
- Python 3 with Ansible, Boto3

**Pull Command:**
```bash
docker pull redluit/jenkins-custom:latest
```

**Usage:**
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  redluit/jenkins-custom:latest
```

**Docker Hub:** https://hub.docker.com/r/redluit/jenkins-custom

---

### 2. Docker01 (`redluit/nov2025-docker01`)

**Source:** `docker01/Dockerfile`

**Description:** Docker01 project image

**Pull Command:**
```bash
docker pull redluit/nov2025-docker01:latest
```

**Docker Hub:** https://hub.docker.com/r/redluit/nov2025-docker01

---

### 3. Docker02 (`redluit/nov2025-docker02`)

**Source:** `docker02/Dockerfile`

**Description:** Docker02 project image

**Pull Command:**
```bash
docker pull redluit/nov2025-docker02:latest
```

**Docker Hub:** https://hub.docker.com/r/redluit/nov2025-docker02

---

## Workflow: `docker-publish-all.yml`

### How It Works

1. **Change Detection**
   - Automatically detects which Dockerfiles have changed
   - Only builds and publishes images that were modified
   - Uses path filters to track changes in `complex/`, `docker01/`, `docker02/`

2. **Build & Publish**
   - Uses matrix strategy to build multiple images in parallel
   - Tags images with multiple tags (latest, branch name, commit SHA, version)
   - Pushes to Docker Hub repositories
   - Generates attestation for supply chain security

3. **Security Scanning**
   - Runs Trivy vulnerability scanner on all published images
   - Uploads results to GitHub Security tab
   - Reports CRITICAL and HIGH severity issues

4. **Testing**
   - Pulls published images from Docker Hub
   - Runs basic smoke tests to verify functionality
   - For Jenkins image: verifies all tools are installed

5. **Notification**
   - Generates comprehensive summary
   - Lists all published images with pull commands
   - Links to Docker Hub repositories

### Triggers

**Automatic (on push to `main`):**
```yaml
push:
  branches:
    - main
  paths:
    - 'complex/**'
    - 'docker01/**'
    - 'docker02/**'
```

**Manual Dispatch:**
```yaml
workflow_dispatch:
  inputs:
    images: 'all'  # or 'complex,docker01'
    tag_suffix: '-beta'  # optional
```

**Pull Request (build only, no publish):**
```yaml
pull_request:
  branches:
    - main
    - dev
```

### Image Tags

Each image is tagged with multiple tags for flexibility:

| Tag Format | Example | Description |
|------------|---------|-------------|
| `latest` | `latest` | Latest stable from main branch |
| `<branch>` | `main` | Branch name |
| `<branch>-<sha>` | `main-abc1234` | Branch + commit SHA |
| `v<version>` | `v1.0.0` | Semantic version (when tagged) |
| `<major>.<minor>` | `1.0` | Major.minor version |
| `<major>` | `1` | Major version only |
| Custom suffix | `latest-beta` | When using tag_suffix input |

### Required Secrets

The workflow requires Docker Hub credentials stored as GitHub Secrets:

| Secret | Description | Example |
|--------|-------------|---------|
| `DOCKER_USERNAME` | Docker Hub username | `redluit` |
| `DOCKER_PASSWORD` | Docker Hub access token | `dckr_pat_xxx...` |

**Setting up secrets:**

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add `DOCKER_USERNAME` with your Docker Hub username
4. Add `DOCKER_PASSWORD` with your Docker Hub access token

**Creating Docker Hub access token:**

1. Go to https://hub.docker.com/settings/security
2. Click **New Access Token**
3. Name: `GitHub Actions - redLUIT_Nov2025_Docker1234`
4. Permissions: **Read, Write, Delete**
5. Generate and copy the token
6. Add it as `DOCKER_PASSWORD` secret

## Manual Publishing

### Publish All Images

```bash
# Via GitHub UI
Go to Actions → Docker Hub Publishing → Run workflow
Select: images = "all"
```

### Publish Specific Images

```bash
# Via GitHub UI
Go to Actions → Docker Hub Publishing → Run workflow
Select: images = "complex,docker01"
```

### With Custom Tag Suffix

```bash
# Via GitHub UI
Go to Actions → Docker Hub Publishing → Run workflow
Select:
  - images = "all"
  - tag_suffix = "-beta"
# Results in: redluit/jenkins-custom:latest-beta
```

## Local Publishing

You can also publish images locally:

### Jenkins Custom Image

```bash
cd complex

# Build
docker build -t redluit/jenkins-custom:latest .

# Login to Docker Hub
docker login

# Push
docker push redluit/jenkins-custom:latest
```

### Docker01

```bash
cd docker01

docker build -t redluit/nov2025-docker01:latest .
docker push redluit/nov2025-docker01:latest
```

## Using Published Images

### Jenkins Custom - Quick Start

**Option 1: Direct Run**
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  redluit/jenkins-custom:latest

# Get admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Access at http://localhost:8080
```

**Option 2: With Docker Compose**
```yaml
version: '3.8'

services:
  jenkins:
    image: redluit/jenkins-custom:latest
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_data:/var/jenkins_home
    restart: unless-stopped

volumes:
  jenkins_data:
```

**Option 3: With Kubernetes**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: redluit/jenkins-custom:latest
        ports:
        - containerPort: 8080
        - containerPort: 50000
        volumeMounts:
        - name: jenkins-data
          mountPath: /var/jenkins_home
      volumes:
      - name: jenkins-data
        persistentVolumeClaim:
          claimName: jenkins-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    targetPort: 8080
    name: ui
  - port: 50000
    targetPort: 50000
    name: agent
  selector:
    app: jenkins
```

## Monitoring Published Images

### Check Image on Docker Hub

```bash
# View image details
https://hub.docker.com/r/redluit/jenkins-custom

# View tags
https://hub.docker.com/r/redluit/jenkins-custom/tags
```

### Pull and Inspect Locally

```bash
# Pull image
docker pull redluit/jenkins-custom:latest

# Inspect image
docker inspect redluit/jenkins-custom:latest

# View image history
docker history redluit/jenkins-custom:latest

# View image size
docker images redluit/jenkins-custom:latest
```

### Security Scanning

```bash
# Scan with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image redluit/jenkins-custom:latest

# Scan with Snyk
snyk container test redluit/jenkins-custom:latest
```

## Troubleshooting

### Build Fails

**Check Dockerfile syntax:**
```bash
cd complex
docker build -t test .
```

**Check workflow logs:**
- Go to Actions tab
- Click on failed workflow run
- Expand failed job step

### Push Fails

**Verify Docker Hub credentials:**
```bash
docker login
# Enter DOCKER_USERNAME and DOCKER_PASSWORD
```

**Check repository exists:**
- Go to https://hub.docker.com/
- Verify `redluit/jenkins-custom` repository exists
- Check repository permissions

### Image Pull Fails

**Check if image exists:**
```bash
docker pull redluit/jenkins-custom:latest
```

**Check Docker Hub status:**
- https://status.docker.com/

**Try with specific tag:**
```bash
docker pull redluit/jenkins-custom:main-abc1234
```

## Best Practices

### Versioning

1. **Use semantic versioning** for releases:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. **Tag format:** `v<major>.<minor>.<patch>`
   - Major: Breaking changes
   - Minor: New features (backward compatible)
   - Patch: Bug fixes

### Security

1. **Scan images** before deploying to production
2. **Update base images** regularly
3. **Review Trivy reports** in GitHub Security tab
4. **Use specific tags** in production (not `latest`)

### Performance

1. **Use build cache** - workflow automatically caches layers
2. **Multi-stage builds** - reduce final image size
3. **Minimize layers** - combine RUN commands
4. **Clean up** - remove temporary files in same layer

### Documentation

1. **Update README** when changing Dockerfiles
2. **Document environment variables** required
3. **Provide usage examples**
4. **List installed tools** and versions

## CI/CD Integration

### Use in GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Jenkins
        run: |
          docker pull redluit/jenkins-custom:latest
          docker run -d \
            --name jenkins \
            -p 8080:8080 \
            redluit/jenkins-custom:latest
```

### Use with Terraform

```hcl
resource "docker_image" "jenkins" {
  name = "redluit/jenkins-custom:latest"
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.image_id
  name  = "jenkins"

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }

  volumes {
    volume_name    = "jenkins_data"
    container_path = "/var/jenkins_home"
  }
}
```

### Use with Ansible

```yaml
- name: Deploy Jenkins from Docker Hub
  docker_container:
    name: jenkins
    image: redluit/jenkins-custom:latest
    state: started
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_data:/var/jenkins_home
    restart_policy: unless-stopped
```

## Resources

- [Docker Hub - redluit](https://hub.docker.com/u/redluit)
- [GitHub Actions Workflow](./.github/workflows/docker-publish-all.yml)
- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Docker Image](https://hub.docker.com/_/jenkins)
- [Trivy Scanner](https://github.com/aquasecurity/trivy)

---

**Last Updated:** December 2024
**Maintained by:** redLUIT Team
**Repository:** https://github.com/redluit/redLUIT_Nov2025_Docker1234
