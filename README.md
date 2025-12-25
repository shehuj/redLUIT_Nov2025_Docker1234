# Jenkins Docker Deployment - All Levels

Complete Jenkins deployment guide demonstrating three levels of Docker expertise: Foundational (CLI), Advanced (Docker Compose), and Complex (Custom Images).

[![Foundational CI](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/foundational-ci.yml/badge.svg)](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/foundational-ci.yml)
[![Advanced CI](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/advanced-ci.yml/badge.svg)](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/advanced-ci.yml)
[![Complex CI](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/complex-ci.yml/badge.svg)](https://github.com/redluit/redLUIT_Nov2025_Docker1234/actions/workflows/complex-ci.yml)

## 📋 Overview

This repository demonstrates three distinct approaches to deploying Jenkins with Docker, each building upon the previous level:

| Level | Method | Key Concepts | Difficulty |
|-------|--------|--------------|------------|
| **Foundational** | CLI Commands | Basic Docker operations, volumes, containers | ⭐ Beginner |
| **Advanced** | Docker Compose | Service orchestration, networks, health checks | ⭐⭐ Intermediate |
| **Complex** | Custom Dockerfile | Image building, multi-layer, optimization | ⭐⭐⭐ Advanced |

## 🎯 Learning Objectives

By completing all three levels, you will learn to:

- ✅ Pull and run Docker images from Docker Hub
- ✅ Create and manage Docker volumes for data persistence
- ✅ Map container ports to host machine
- ✅ Execute commands inside running containers
- ✅ Verify data persistence across container recreation
- ✅ Use Docker Compose for service orchestration
- ✅ Build custom Docker images from Dockerfiles
- ✅ Install additional tools and software in containers
- ✅ Pre-configure applications using Configuration as Code
- ✅ Implement CI/CD pipelines with GitHub Actions
- ✅ Clean up Docker resources properly

## 🚀 Quick Start

### Prerequisites

- **Docker**: Version 20.10+
- **Docker Compose**: V2 (or standalone V1.29+)
- **Git**: For cloning the repository
- **Bash**: For running scripts
- **Ports**: 8080 and 50000 available
- **Disk Space**: 4GB+ recommended

### Clone the Repository

```bash
git clone https://github.com/redluit/redLUIT_Nov2025_Docker1234.git
cd redLUIT_Nov2025_Docker1234
```

### Choose Your Level

#### Option 1: Foundational Level (CLI Commands)

```bash
cd foundational
chmod +x *.sh
./01-setup-jenkins.sh
```

[📖 View Foundational README](./foundational/README.md)

#### Option 2: Advanced Level (Docker Compose)

```bash
cd advanced
chmod +x *.sh
./01-setup-jenkins.sh
```

[📖 View Advanced README](./advanced/README.md)

#### Option 3: Complex Level (Custom Image)

```bash
cd complex
chmod +x *.sh
./05-deploy-all.sh
```

[📖 View Complex README](./complex/README.md)

## 📁 Repository Structure

```
redLUIT_Nov2025_Docker1234/
├── foundational/               # Level 1: CLI-based deployment
│   ├── 01-setup-jenkins.sh    # Pull image, create volume, run container
│   ├── 02-verify-persistence.sh # Test data persistence
│   ├── 03-cleanup.sh          # Remove all resources
│   └── README.md              # Detailed documentation
│
├── advanced/                   # Level 2: Docker Compose deployment
│   ├── docker-compose.yml     # Service definition
│   ├── 01-setup-jenkins.sh    # Start services
│   ├── 02-verify-persistence.sh # Test persistence
│   ├── 03-cleanup.sh          # Remove all resources
│   └── README.md              # Detailed documentation
│
├── complex/                    # Level 3: Custom Docker image
│   ├── Dockerfile             # Custom image definition
│   ├── plugins.txt            # Jenkins plugins to install
│   ├── jenkins.yaml           # Configuration as Code (CasC)
│   ├── 01-build-image.sh      # Build custom image
│   ├── 02-create-volume.sh    # Create volume
│   ├── 03-run-container.sh    # Run custom container
│   ├── 04-get-password.sh     # Retrieve admin password
│   ├── 05-deploy-all.sh       # All-in-one deployment
│   ├── 06-cleanup-all.sh      # Complete cleanup
│   └── README.md              # Detailed documentation
│
├── .github/workflows/          # CI/CD workflows
│   ├── foundational-ci.yml    # Test foundational level
│   ├── advanced-ci.yml        # Test advanced level
│   ├── complex-ci.yml         # Test complex level
│   └── all-levels-ci.yml      # Test all levels
│
└── README.md                   # This file

```

## 📚 Detailed Level Descriptions

### Foundational Level: CLI Commands

**What you'll learn:**
- Basic Docker CLI commands
- Image pulling from Docker Hub
- Volume creation and management
- Container lifecycle management
- Port mapping
- Data persistence verification

**Scripts:**
- `01-setup-jenkins.sh`: Automates Jenkins setup
- `02-verify-persistence.sh`: Tests data persistence
- `03-cleanup.sh`: Removes all resources

**Time to complete**: ~15 minutes

[→ Start Foundational Level](./foundational/README.md)

### Advanced Level: Docker Compose

**What you'll learn:**
- Docker Compose file syntax
- Service orchestration
- Automated networking
- Health checks
- Environment variables
- Multi-container management

**Files:**
- `docker-compose.yml`: Service definitions
- Management scripts for easy operation

**Time to complete**: ~20 minutes

[→ Start Advanced Level](./advanced/README.md)

### Complex Level: Custom Docker Image

**What you'll learn:**
- Dockerfile creation and optimization
- Multi-stage builds
- Installing system packages
- Pre-installing Jenkins plugins
- Configuration as Code (CasC)
- Image layer optimization
- Security best practices

**Components:**
- Custom Dockerfile with multiple tools
- Pre-installed plugins (Git, Docker, Kubernetes, Ansible)
- Pre-configured Jenkins using CasC
- Comprehensive management scripts

**Time to complete**: ~40 minutes

[→ Start Complex Level](./complex/README.md)

## 🔄 CI/CD Workflows

All three levels include GitHub Actions workflows for automated testing:

### Foundational CI
- Tests CLI deployment scripts
- Verifies container creation
- Tests data persistence
- Validates cleanup
- Runs ShellCheck linting

### Advanced CI
- Validates docker-compose.yml
- Tests Docker Compose deployment
- Verifies health checks
- Tests multiple Compose versions
- Validates service orchestration

### Complex CI
- Lints Dockerfile with Hadolint
- Builds custom image
- Tests installed tools
- Verifies plugin installation
- Scans for vulnerabilities with Trivy
- Tests Configuration as Code
- Validates data persistence

### All Levels CI
- Runs all levels sequentially
- Performs integration testing
- Validates README files
- Runs on schedule (weekly)
- Manual trigger with level selection

## 🎓 Requirements Fulfilled

This repository meets all specified requirements:

### Foundational Requirements ✅
- [x] Pull Jenkins LTS image from Docker Hub
- [x] Create Docker volume for data persistence
- [x] Run container with volume and correct ports
- [x] Retrieve admin password
- [x] Login and create new user
- [x] Launch new container with same volume
- [x] Verify data persistence

### Advanced Requirements ✅
- [x] All foundational steps using Docker Compose
- [x] Service orchestration
- [x] Automated networking
- [x] Health monitoring

### Complex Requirements ✅
- [x] Create Dockerfile with necessary commands
- [x] Build image from Dockerfile
- [x] Create volume for data persistence
- [x] Map correct ports
- [x] Retrieve admin password
- [x] Login and create user
- [x] Remove container, volume, and image
- [x] Complete cleanup verification

### CI/CD Requirements ✅
- [x] GitHub Actions workflows for all levels
- [x] Automated testing on push/PR
- [x] Security scanning
- [x] Linting and validation
- [x] Integration testing

## 🛠️ Troubleshooting

### Port Already in Use

If port 8080 is already in use:

**Foundational:**
```bash
# Edit the docker run command to use a different port
docker run -d ... -p 8081:8080 ...
```

**Advanced:**
```yaml
# Edit docker-compose.yml
ports:
  - "8081:8080"
```

**Complex:**
```bash
# Edit 03-run-container.sh
HTTP_PORT="8081"
```

### Docker Not Running

```bash
# Check Docker status
docker info

# Start Docker (macOS)
open -a Docker

# Start Docker (Linux)
sudo systemctl start docker
```

### Permission Denied

```bash
# Add your user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker
```

### Cleanup Not Working

```bash
# Force remove all Jenkins containers
docker ps -a | grep jenkins | awk '{print $1}' | xargs docker rm -f

# Force remove all Jenkins volumes
docker volume ls | grep jenkins | awk '{print $2}' | xargs docker volume rm -f

# Remove all Jenkins images
docker images | grep jenkins | awk '{print $3}' | xargs docker rmi -f
```

## 📖 Additional Resources

### Official Documentation
- [Jenkins Official Docs](https://www.jenkins.io/doc/)
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

### Learning Resources
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### Community
- [Jenkins Community](https://www.jenkins.io/participate/)
- [Docker Community](https://www.docker.com/community/)
- [Stack Overflow - Jenkins](https://stackoverflow.com/questions/tagged/jenkins)
- [Stack Overflow - Docker](https://stackoverflow.com/questions/tagged/docker)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test all three levels
5. Commit your changes (`git commit -m 'Add improvement'`)
6. Push to the branch (`git push origin feature/improvement`)
7. Open a Pull Request

## 📝 Testing Your Changes

Before submitting a PR, run:

```bash
# Test foundational level
cd foundational && chmod +x *.sh && ./01-setup-jenkins.sh && ./03-cleanup.sh

# Test advanced level
cd ../advanced && chmod +x *.sh && ./01-setup-jenkins.sh && ./03-cleanup.sh

# Test complex level
cd ../complex && chmod +x *.sh && ./05-deploy-all.sh && echo "yes" | ./06-cleanup-all.sh
```

## 🔒 Security Considerations

- **Default Credentials**: Change default passwords in production
- **Network Exposure**: Don't expose Jenkins directly to the internet
- **Secrets Management**: Use Docker secrets or environment variables
- **Regular Updates**: Keep Jenkins and Docker up to date
- **Plugin Security**: Only install trusted Jenkins plugins
- **Image Scanning**: Regularly scan images for vulnerabilities

## 📊 Performance Tips

- **Resource Limits**: Set memory/CPU limits for containers
- **Volume Drivers**: Use appropriate volume drivers for your environment
- **Image Optimization**: Use multi-stage builds to reduce image size
- **Caching**: Leverage Docker build cache effectively
- **Plugin Selection**: Only install necessary Jenkins plugins

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **redLUIT Team** - *Initial work*

## 🙏 Acknowledgments

- Jenkins community for excellent documentation
- Docker community for best practices guidance
- Contributors and testers

## 📞 Support

For issues and questions:
- Open an [Issue](https://github.com/redluit/redLUIT_Nov2025_Docker1234/issues)
- Check existing [Discussions](https://github.com/redluit/redLUIT_Nov2025_Docker1234/discussions)
- Review the README files in each level directory

## 🎯 What's Next?

After completing all three levels, consider:

1. **Deploy Jenkins Agents**: Add worker nodes to your Jenkins setup
2. **Integrate with Kubernetes**: Deploy Jenkins on Kubernetes
3. **Add Monitoring**: Integrate Prometheus and Grafana
4. **Implement Backups**: Automate Jenkins backup and restore
5. **CI/CD Pipelines**: Create real-world Jenkins pipelines
6. **Security Hardening**: Implement advanced security measures
7. **High Availability**: Set up Jenkins in HA configuration

---

**Last Updated**: December 2024
**Repository**: [redLUIT_Nov2025_Docker1234](https://github.com/redluit/redLUIT_Nov2025_Docker1234)
**Maintained by**: redLUIT Team
