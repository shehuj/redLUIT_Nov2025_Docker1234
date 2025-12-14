# Full CI/CD Workflow Guide - docker-01-deploy.yml

## 🎯 Overview

The consolidated `docker-01-deploy.yml` workflow combines the best features from both the original `docker-01-deploy.yml` and `docker-publish02.yml`, creating an enterprise-grade CI/CD pipeline with optional EC2 deployment.

---

## 📋 Table of Contents

- [Features](#features)
- [Workflow Structure](#workflow-structure)
- [Triggers](#triggers)
- [Jobs Breakdown](#jobs-breakdown)
- [Enabling EC2 Deployment](#enabling-ec2-deployment)
- [Required Secrets](#required-secrets)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## ✨ Features

### From docker-publish02.yml (Enterprise Features)
✅ **Multi-stage validation**
- Configuration validation
- Dockerfile verification
- Dependency checks

✅ **Comprehensive testing**
- Python unit tests with pytest
- Code coverage reporting
- Security dependency scanning (Safety, Bandit)
- Code quality checks (Ruff, Flake8)

✅ **Triple security scanning**
- Semgrep SAST analysis
- Trivy container vulnerability scanning
- Grype alternative vulnerability scanning

✅ **Production-ready publishing**
- Multi-platform builds (linux/amd64, linux/arm64)
- SBOM (Software Bill of Materials) generation
- Image provenance for supply chain security
- GitHub Actions caching for faster builds
- Automated GitHub Releases on version tags

✅ **Advanced features**
- PR commenting with test results
- Workflow dispatch with environment selection
- Concurrency control (cancels old runs)
- Comprehensive build summaries

### From docker-01-deploy.yml (Deployment Features)
✅ **EC2 deployment capability** (commented out, ready to enable)
- SSH-based deployment
- Health checks
- Automatic container restart
- Image cleanup

✅ **Container health verification**
- HTTP health checks
- Content validation
- Post-deployment verification

---

## 🏗️ Workflow Structure

```
Pull Request Flow:
┌────────────────────────┐
│  PR to main/dev        │
│  (docker01/ changes)   │
└──────────┬─────────────┘
           │
    ┌──────▼──────┐
    │  Validate   │ ── Checks Dockerfile, requirements
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │    Test     │ ── Python tests, linting, security
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │Build & Scan │ ── Build image, triple security scan
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │ PR Comment  │ ── Posts results to PR
    └─────────────┘


Main Branch Flow:
┌────────────────────────┐
│  Push to main          │
│  (docker01/ changes)   │
└──────────┬─────────────┘
           │
    ┌──────▼──────┐
    │   Publish   │ ── Build multi-platform, scan, push
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │Generate SBOM│ ── Supply chain security
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │   Verify    │ ── Pull and test published image
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │   Deploy    │ ── COMMENTED OUT (Enable manually)
    └─────────────┘     SSH to EC2, deploy container
```

---

## 🎬 Triggers

### Automatic Triggers

**Pull Requests** - Runs validation, tests, and scans
```yaml
on:
  pull_request:
    branches: [main, dev]
    paths:
      - 'docker01/**'
      - '.github/workflows/docker-01-deploy.yml'
```

**Push to Main** - Builds, scans, and publishes to Docker Hub
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'docker01/**'
      - '.github/workflows/docker-01-deploy.yml'
```

**Version Tags** - Creates GitHub Releases
```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

### Manual Trigger

**Workflow Dispatch** - Manual runs with options
```yaml
on:
  workflow_dispatch:
    inputs:
      environment: [staging, production]
      skip_tests: [true, false]
```

---

## 🔧 Jobs Breakdown

### 1. **Validate Job** (PR only)
- ⏱️ Duration: ~30 seconds
- 🎯 Purpose: Quick validation before expensive operations
- ✅ Checks:
  - Dockerfile exists at `./docker01/Dockerfile`
  - requirements.txt present (optional)
  - tests directory exists (optional)

### 2. **Test Job** (PR only)
- ⏱️ Duration: ~2-5 minutes
- 🎯 Purpose: Comprehensive code quality and security checks
- ✅ Activities:
  - Python 3.12 setup with pip caching
  - Install dependencies
  - Run Safety (dependency security)
  - Run Bandit (code security)
  - Run pytest with coverage
  - Run Ruff and Flake8 linting
  - Upload test artifacts
  - Comment results on PR

### 3. **Build-and-Scan Job** (PR only)
- ⏱️ Duration: ~10-15 minutes
- 🎯 Purpose: Build image and perform security analysis
- ✅ Activities:
  - Build Docker image (validation, not pushed)
  - Start container and health check
  - Verify HTML content exists
  - Semgrep SAST scan
  - Trivy vulnerability scan (SARIF + JSON + Table)
  - Grype vulnerability scan
  - Parse vulnerability counts
  - Upload security results to GitHub Security tab
  - Comment scan summary on PR

**Example PR Comment:**
```markdown
## ✅ Security Scan Results - Docker Image 01

### 📦 Docker Image Built Successfully
- **Tags:** `pr-123-abc1234`

### 🔒 Vulnerability Summary
| Severity | Count |
|----------|-------|
| Critical | 0     |
| High     | 2     |

### 📊 Security Tools Used
- ✅ Semgrep SAST Analysis
- ✅ Trivy Container Scan
- ✅ Grype Vulnerability Scan
- ✅ Container Health Check
```

### 4. **Publish Job** (Main branch only)
- ⏱️ Duration: ~15-20 minutes
- 🎯 Purpose: Build production-ready, multi-platform images
- ✅ Activities:
  - Pre-publish validation tests
  - Setup QEMU for multi-arch
  - Login to Docker Hub
  - Extract semantic versioning metadata
  - Build for scanning
  - Trivy final security check
  - **Fail on CRITICAL vulnerabilities**
  - Build and push multi-platform (amd64 + arm64)
  - Generate SBOM
  - Verify published image
  - Create GitHub Release (on version tags)
  - Generate comprehensive summary

**Published Tags:**
- `latest` (main branch)
- `main-<sha>` (commit SHA)
- `v1.2.3` (version tags)
- `v1.2` (major.minor)
- `v1` (major)

### 5. **Deploy Job** (COMMENTED OUT)
- ⏱️ Duration: ~2-3 minutes
- 🎯 Purpose: Deploy to EC2 instance
- ⚠️ Status: **DISABLED** - Must be manually enabled

---

## 🚀 Enabling EC2 Deployment

The deployment job is **commented out** and ready to enable when needed.

### Step 1: Configure GitHub Secrets

Navigate to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `EC2_HOST` | EC2 instance IP or hostname | `54.123.45.67` or `myapp.example.com` |
| `EC2_USERNAME` | SSH username | `ec2-user` (Amazon Linux) or `ubuntu` (Ubuntu) |
| `EC2_SSHKEY` | Private SSH key | Contents of your `.pem` file |

### Step 2: Prepare EC2 Instance

SSH into your EC2 instance and ensure:

```bash
# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Verify Docker works
docker --version
docker ps

# Allow HTTP traffic
# In AWS Console: Security Group → Inbound Rules → Add HTTP (port 80)
```

### Step 3: Uncomment the Deploy Job

In `.github/workflows/docker-01-deploy.yml`, find lines **697-785** and remove the `#` comment characters:

**Before:**
```yaml
# deploy:
#   name: Deploy to EC2
#   runs-on: ubuntu-latest
```

**After:**
```yaml
deploy:
  name: Deploy to EC2
  runs-on: ubuntu-latest
```

**Pro Tip:** Use multi-cursor editing in your IDE to uncomment quickly:
1. Select lines 714-785
2. Use `Ctrl+/` (Windows/Linux) or `Cmd+/` (Mac) to toggle comments

### Step 4: Test Deployment

1. Make a small change to `docker01/` folder
2. Commit and push to main branch
3. Watch the workflow run
4. Verify deployment at `http://YOUR_EC2_HOST`

---

## 🔑 Required Secrets

### Mandatory Secrets

| Secret | Required For | How to Get |
|--------|-------------|------------|
| `DOCKER_USERNAME` | Publishing to Docker Hub | Your Docker Hub username |
| `DOCKER_PASSWORD` | Publishing to Docker Hub | Docker Hub access token ([Create here](https://hub.docker.com/settings/security)) |

### Optional Secrets

| Secret | Required For | Notes |
|--------|-------------|-------|
| `EC2_HOST` | EC2 deployment | Only if deployment enabled |
| `EC2_USERNAME` | EC2 deployment | Only if deployment enabled |
| `EC2_SSHKEY` | EC2 deployment | Only if deployment enabled |
| `SEMGREP_APP_TOKEN` | Enhanced SAST scanning | Free tier available at [semgrep.dev](https://semgrep.dev) |

---

## 📚 Usage Examples

### Example 1: Regular Development Workflow

```bash
# 1. Create a feature branch
git checkout -b feature/add-new-section

# 2. Make changes to docker01/
echo "<h2>New Feature</h2>" >> docker01/index.html

# 3. Commit and push
git add docker01/
git commit -m "feat: add new section to homepage"
git push origin feature/add-new-section

# 4. Create PR on GitHub
# → Workflow runs: validate → test → build-and-scan
# → PR comment shows results

# 5. Merge PR after approval
# → Workflow runs: publish (builds + pushes to Docker Hub)
# → If deploy enabled: deploys to EC2
```

### Example 2: Manual Workflow Run

```bash
# Trigger workflow manually via GitHub UI:
Actions → Full CI/CD Pipeline → Run workflow

# Select options:
Environment: production
Skip tests: false (only use true for emergencies)
```

### Example 3: Create a Release

```bash
# Tag a new version
git tag v1.2.3
git push origin v1.2.3

# → Workflow runs: publish job
# → Creates GitHub Release with:
#   - SBOM file
#   - Trivy security report
#   - Auto-generated release notes
```

### Example 4: Testing Without Triggering Workflow

```bash
# Make changes outside docker01/
echo "# Testing" >> README.md
git add README.md
git commit -m "docs: update README"
git push origin main

# ✅ Workflow does NOT run (no docker01/ changes)
```

---

## 🐛 Troubleshooting

### Issue 1: Workflow Not Triggering

**Problem:** Made changes but workflow didn't run

**Solution:**
```bash
# Check if changes were in docker01/
git diff HEAD~1 --name-only

# If files are outside docker01/, workflow won't trigger
# This is by design to save CI/CD minutes
```

### Issue 2: Docker Hub Push Fails

**Problem:** `docker/login-action@v3` fails

**Solution:**
1. Verify secrets are set:
   - Go to Settings → Secrets → Actions
   - Check `DOCKER_USERNAME` exists
   - Check `DOCKER_PASSWORD` exists
2. Generate new Docker Hub access token
3. Update `DOCKER_PASSWORD` secret

### Issue 3: Trivy Scan Blocks Deployment

**Problem:** Workflow fails at "Run Trivy for blocking vulnerabilities"

**Solution:**
```yaml
# This is intentional! The workflow blocks on CRITICAL vulnerabilities
# Options:
# 1. Fix the vulnerabilities (recommended)
# 2. Temporarily allow critical vulns (not recommended):
- name: Run Trivy for blocking vulnerabilities
  continue-on-error: true  # Add this line
```

### Issue 4: EC2 Deployment Fails

**Problem:** SSH connection fails

**Solution:**
```bash
# Check EC2 security group allows SSH (port 22)
# From GitHub Actions IP ranges

# Verify SSH key format
cat $EC2_SSHKEY | head -1
# Should show: -----BEGIN RSA PRIVATE KEY-----

# Test manually:
ssh -i your-key.pem ec2-user@YOUR_EC2_HOST
```

### Issue 5: Tests Failing

**Problem:** Test job fails

**Solution:**
```bash
# Run tests locally first
cd docker01/
pip install -r requirements.txt
pip install pytest ruff flake8
pytest tests/ -v

# Fix errors locally before pushing
```

---

## 📊 Workflow Comparison

| Feature | Original docker-01 | Original docker-publish02 | New Consolidated |
|---------|-------------------|-------------------------|------------------|
| Validation | ❌ | ✅ | ✅ |
| Python Tests | ❌ | ✅ | ✅ |
| Security Scans | 1 (Trivy) | 3 (Semgrep, Trivy, Grype) | 3 |
| Multi-platform | ❌ | ✅ | ✅ |
| SBOM | ❌ | ✅ | ✅ |
| EC2 Deploy | ✅ | ❌ | ✅ (commented) |
| PR Comments | ❌ | ✅ | ✅ |
| GitHub Releases | ❌ | ✅ | ✅ |
| Workflow Dispatch | ❌ | ✅ | ✅ |
| Path Filters | ✅ | ❌ | ✅ |

---

## 🎓 Best Practices

### 1. Use Feature Branches
```bash
# Bad
git commit -m "fix" && git push origin main

# Good
git checkout -b fix/security-update
git commit -m "fix: update vulnerable dependency"
git push origin fix/security-update
# Create PR → Review → Merge
```

### 2. Semantic Versioning
```bash
# Use conventional commits
git commit -m "feat: add user authentication"  # Minor version bump
git commit -m "fix: resolve memory leak"       # Patch version bump
git commit -m "feat!: redesign API"            # Major version bump

# Tag releases
git tag v1.2.3
git push origin v1.2.3
```

### 3. Review Security Scan Results
- Always check PR comments for vulnerability counts
- Don't merge PRs with CRITICAL vulnerabilities
- Review SARIF results in Security tab

### 4. Monitor Docker Hub Usage
- Free tier: 200 pulls/6 hours
- Upgrade if you hit limits
- Use caching to reduce builds

---

## 📈 Performance Optimization

### Caching Strategy
The workflow uses GitHub Actions cache for:
- Python pip dependencies
- Docker buildx layers
- Test results

This reduces build times from ~20 minutes to ~8 minutes for unchanged dependencies.

### Concurrency Control
Only one workflow runs per branch at a time. New pushes cancel old runs:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

---

## 🔐 Security Features

1. **SARIF Upload**: All security scans upload to GitHub Security tab
2. **Secret Scanning**: Semgrep checks for leaked secrets
3. **Dependency Scanning**: Safety checks Python dependencies
4. **Container Scanning**: Trivy + Grype for comprehensive coverage
5. **SBOM Generation**: Track all dependencies for supply chain security
6. **Provenance**: Cryptographic proof of build origin

---

## 📝 Changelog

### v2.0.0 - Consolidated Workflow
- ✅ Merged docker-01-deploy.yml and docker-publish02.yml
- ✅ Added comprehensive testing and scanning
- ✅ Added multi-platform support
- ✅ Added SBOM generation
- ✅ Deployment section commented out (ready to enable)
- ✅ Added workflow dispatch
- ✅ Added PR commenting
- ✅ Added GitHub Releases support

### v1.0.0 - Original Workflows
- Basic build and deploy (docker-01-deploy.yml)
- Enterprise publishing (docker-publish02.yml)

---

## 🆘 Support

If you encounter issues:

1. **Check workflow logs**: Actions → Failed run → Click on failed step
2. **Review this guide**: Especially the Troubleshooting section
3. **Test locally**: Run commands locally before pushing
4. **Check secrets**: Ensure all required secrets are configured

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Semgrep Documentation](https://semgrep.dev/docs/)
- [SSH Action Documentation](https://github.com/appleboy/ssh-action)

---

**Last Updated:** December 2024
**Maintained by:** DevOps Team
