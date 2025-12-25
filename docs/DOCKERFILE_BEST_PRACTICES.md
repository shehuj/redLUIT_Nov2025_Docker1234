# Dockerfile Best Practices

This document explains the Dockerfile best practices applied in this repository and the rationale behind our Hadolint configuration.

## Hadolint Configuration

We use [Hadolint](https://github.com/hadolint/hadolint) to lint our Dockerfiles and enforce best practices.

### Configuration File: `.hadolint.yaml`

```yaml
ignored:
  - DL3008

failure-threshold: error

trustedRegistries:
  - docker.io
  - jenkins
```

## Ignored Rules

### DL3008: Pin versions in apt-get install

**Rule**: Hadolint recommends pinning package versions in `apt-get install` commands.

**Why we ignore it**:

1. **Package Version Volatility**: Debian/Ubuntu package versions change frequently
2. **Security Updates**: We want to receive security updates from the base image
3. **Portability**: Pinning makes Dockerfiles less portable across different base image versions
4. **Base Image Trust**: We use `jenkins/jenkins:lts` which is regularly updated and maintained
5. **Maintenance Burden**: Constantly updating pinned versions is impractical

**Example**:
```dockerfile
# Hadolint wants this:
RUN apt-get install -y git=1:2.34.1-1ubuntu1.8

# We use this instead:
RUN apt-get install -y --no-install-recommends git
```

**Trade-off**: We accept potential reproducibility issues in exchange for automatic security updates and easier maintenance.

## Applied Best Practices

### ✅ DL3015: Avoid additional packages with --no-install-recommends

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    curl
```

**Benefit**: Reduces image size by ~40-50 MB by not installing recommended packages.

### ✅ DL4001: Use either Wget or Curl, not both

```dockerfile
# Before (mixed):
RUN curl -O https://example.com/file1.tar.gz
RUN wget https://example.com/file2.zip

# After (consistent):
RUN curl -fsSL https://example.com/file1.tar.gz -o file1.tar.gz
RUN curl -fsSL https://example.com/file2.zip -o file2.zip
```

**Benefit**: Consistency and smaller image size (no need for both tools).

### ✅ DL3013: Pin versions in pip install

```dockerfile
RUN pip3 install --no-cache-dir \
    ansible==9.1.0 \
    boto3==1.34.27 \
    botocore==1.34.27
```

**Benefit**: Reproducible builds with Python packages.

### ✅ Layer Optimization

Combine related commands to reduce layers:

```dockerfile
# Good: Single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y curl
```

### ✅ Clean up in the same layer

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

**Benefit**: Prevents cache directories from being committed to image layers.

### ✅ Use specific tags, not 'latest'

```dockerfile
# Good
FROM jenkins/jenkins:lts

# Avoid
FROM jenkins/jenkins:latest
```

**Benefit**: `lts` provides stability while still being updated. `latest` is unpredictable.

### ✅ Multi-stage builds (when applicable)

For future improvements, consider multi-stage builds:

```dockerfile
# Build stage
FROM jenkins/jenkins:lts as builder
RUN download-and-compile-tools

# Runtime stage
FROM jenkins/jenkins:lts
COPY --from=builder /compiled-tools /usr/local/bin/
```

**Benefit**: Smaller final image by excluding build dependencies.

## Additional Best Practices Applied

### Security

1. **USER directive**: Switch back to non-root user after installations
   ```dockerfile
   USER root
   RUN apt-get install ...
   USER jenkins
   ```

2. **Health checks**: Monitor container health
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=10s \
       CMD curl -f http://localhost:8080/login || exit 1
   ```

3. **Trusted registries**: Only use official images
   ```yaml
   trustedRegistries:
     - docker.io
     - jenkins
   ```

### Performance

1. **--no-cache-dir for pip**: Prevents caching pip downloads
   ```dockerfile
   RUN pip3 install --no-cache-dir ansible
   ```

2. **Clean apt cache**: Remove package lists after installation
   ```dockerfile
   && rm -rf /var/lib/apt/lists/*
   ```

### Maintainability

1. **Comments**: Document why, not what
   ```dockerfile
   # Install Docker for building images in Jenkins pipelines
   RUN apt-get install -y docker.io
   ```

2. **Logical grouping**: Group related installations
   ```dockerfile
   # Python ecosystem
   RUN apt-get install -y python3 python3-pip

   # DevOps tools
   RUN install-kubectl && install-terraform
   ```

## Image Size Optimization

Our optimizations:

| Optimization | Size Reduction |
|--------------|----------------|
| --no-install-recommends | ~50 MB |
| Remove wget, use only curl | ~2 MB |
| Clean apt cache | ~30 MB |
| --no-cache-dir for pip | ~10 MB |
| **Total savings** | **~92 MB** |

## CI/CD Integration

Our GitHub Actions workflows enforce these practices:

```yaml
- name: Run Hadolint
  uses: hadolint/hadolint-action@v3.1.0
  with:
    dockerfile: complex/Dockerfile
    failure-threshold: error
    ignore: DL3008
```

## References

- [Hadolint Rules](https://github.com/hadolint/hadolint#rules)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Jenkins Docker Image](https://github.com/jenkinsci/docker)

## Review Checklist

Before committing Dockerfile changes:

- [ ] Run `hadolint Dockerfile` locally
- [ ] Check image size: `docker images`
- [ ] Verify build cache efficiency
- [ ] Test container startup time
- [ ] Scan for vulnerabilities: `docker scan`
- [ ] Review layer count: `docker history`
- [ ] Test with different base image tags
- [ ] Document any new tools or packages

## Future Improvements

1. Implement multi-stage builds for smaller final images
2. Use BuildKit for better caching and performance
3. Implement image signing and verification
4. Add SBOM (Software Bill of Materials) generation
5. Implement automated security scanning in CI/CD
