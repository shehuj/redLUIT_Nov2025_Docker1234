# CI/CD Workflow Structure

This document explains how the GitHub Actions workflows are organized to work as a cohesive unit.

## Overview

The repository uses a **dev/main branching strategy** where:
- **Dev branch**: Testing only (no deployments)
- **Main branch**: Production deployments & publishing

## Workflow Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    DEVELOPMENT (dev)                     │
│                  Testing Only - No Publish                │
└─────────────────────────────────────────────────────────┘
                            │
                            │ Push/PR
                            ├─────────────┬─────────────┬─────────────┐
                            ▼             ▼             ▼             ▼
                    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
                    │ Foundational│ │  Advanced   │ │   Complex   │
                    │     CI      │ │     CI      │ │     CI      │
                    │             │ │             │ │             │
                    │ Test CLI    │ │Test Compose │ │ Test Custom │
                    │ deployments │ │orchestration│ │image builds │
                    └─────────────┘ └─────────────┘ └─────────────┘
                            │             │             │
                            └─────────────┴─────────────┘
                                        │
                                        │ Merge to main
                                        ▼
┌─────────────────────────────────────────────────────────┐
│                   PRODUCTION (main)                      │
│              Publish & Deploy - Production Ready         │
└─────────────────────────────────────────────────────────┘
                            │
                            ├─────────────┬─────────────┐
                            ▼             ▼             ▼
                    ┌─────────────┐ ┌─────────────┐
                    │docker-02    │ │docker-01    │
                    │  Jenkins    │ │  Deploy     │
                    │             │ │             │
                    │Build & Push │ │Deploy to EC2│
                    │to DockerHub │ │             │
                    └─────────────┘ └─────────────┘
```

## Workflows by Branch

### Dev Branch - Testing Phase

#### 1. **Foundational CI** (`foundational-ci.yml`)
**Trigger:** Push/PR to `dev` when `foundational/**` changes

**Purpose:** Test CLI-based Jenkins deployment scripts

**Actions:**
- ✅ Pull Jenkins LTS image
- ✅ Create Docker volume
- ✅ Run container with volume
- ✅ Verify persistence
- ✅ Test cleanup scripts
- ❌ No deployment
- ❌ No publishing

**Success Criteria:**
- Container starts successfully
- Jenkins accessible at localhost:8080
- Data persists across container recreation
- Cleanup removes all resources

---

#### 2. **Advanced CI** (`advanced-ci.yml`)
**Trigger:** Push/PR to `dev` when `advanced/**` changes

**Purpose:** Test Docker Compose orchestration

**Actions:**
- ✅ Validate docker-compose.yml syntax
- ✅ Start services with Docker Compose
- ✅ Verify health checks
- ✅ Test service restart
- ✅ Verify data persistence
- ✅ Test cleanup
- ❌ No deployment
- ❌ No publishing

**Success Criteria:**
- Compose file is valid
- Services start and reach healthy state
- Jenkins accessible
- Persistence works across restarts
- Complete cleanup successful

---

#### 3. **Complex CI** (`complex-ci.yml`)
**Trigger:** Push/PR to `dev` when `complex/**` changes

**Purpose:** Test custom Jenkins image build

**Actions:**
- ✅ Validate Dockerfile with Hadolint
- ✅ Build custom Docker image locally
- ✅ Verify installed tools (Docker, kubectl, Terraform, Ansible)
- ✅ Test image startup
- ✅ Verify Configuration as Code (CasC)
- ✅ Security scan with Trivy
- ✅ Test data persistence
- ❌ No push to Docker Hub
- ❌ No deployment

**Success Criteria:**
- Dockerfile passes linting
- Image builds successfully
- All tools installed and working
- Jenkins starts and is accessible
- CasC configuration valid
- No critical vulnerabilities
- Local tests pass

---

### Main Branch - Production Phase

#### 4. **Production Jenkins** (`docker-02-jenkins.yml`)
**Trigger:** Push to `main` when `complex/**` changes

**Purpose:** Build and publish production-grade Jenkins to Docker Hub

**Actions:**
- ✅ Build image from `complex/Dockerfile`
- ✅ Run security scan (Trivy)
- ✅ Upload SARIF to GitHub Security
- ✅ Push to Docker Hub: `redluit/jenkins-custom`
- ✅ Multi-platform build (amd64, arm64)
- ✅ Generate build attestation
- ✅ Tag with multiple tags:
  - `latest`
  - `main`
  - `<commit-sha>`
  - Custom suffix (optional)

**Docker Hub Repository:** https://hub.docker.com/r/redluit/jenkins-custom

**Pull Command:**
```bash
docker pull redluit/jenkins-custom:latest
```

**Success Criteria:**
- Image builds successfully
- Security scan completes
- Image pushed to Docker Hub
- Attestation generated
- Summary shows pull commands

---

#### 5. **EC2 Deploy** (`docker-01-deploy.yml`)
**Trigger:** Push to `main` when `docker01/**` changes

**Purpose:** Deploy application to AWS EC2

**Actions:**
- ✅ Build image from `docker01/Dockerfile`
- ✅ Run tests
- ✅ Security scanning
- ✅ Deploy to EC2 instance
- ✅ Verify deployment

**Note:** This workflow is independent and handles EC2-specific deployments.

---

## Trigger Paths

| Workflow | Branch | Trigger Paths | Action |
|----------|--------|---------------|--------|
| **foundational-ci.yml** | dev | `foundational/**` | Test only |
| **advanced-ci.yml** | dev | `advanced/**` | Test only |
| **complex-ci.yml** | dev | `complex/**` | Test only |
| **docker-02-jenkins.yml** | main | `complex/**` | Publish to Docker Hub |
| **docker-01-deploy.yml** | main | `docker01/**` | Deploy to EC2 |

## Development Workflow

### Making Changes

#### 1. Work on Dev Branch
```bash
git checkout dev
# Make changes to foundational/, advanced/, or complex/
git add .
git commit -m "feat: Add new feature"
git push origin dev
```

**Result:** Appropriate CI workflow runs (test only, no publish)

#### 2. Create Pull Request
```bash
gh pr create --base dev --title "Add new feature"
```

**Result:** CI workflows run on PR (test only)

#### 3. Merge to Main
```bash
# After PR approval
git checkout main
git merge dev
git push origin main
```

**Result:** Production workflows run:
- If `complex/` changed → `docker-02-jenkins.yml` publishes to Docker Hub
- If `docker01/` changed → `docker-01-deploy.yml` deploys to EC2

### Example Scenarios

#### Scenario 1: Update Jenkins Custom Image

```bash
# 1. Edit Dockerfile on dev
git checkout dev
vim complex/Dockerfile
git commit -m "feat: Add new tool to Jenkins"
git push origin dev
```
→ **complex-ci.yml** runs: Builds and tests locally

```bash
# 2. Create PR and merge
gh pr create --base dev
# After approval
git checkout main && git merge dev && git push
```
→ **docker-02-jenkins.yml** runs: Builds and publishes to Docker Hub

#### Scenario 2: Update Foundational Scripts

```bash
# 1. Edit scripts on dev
git checkout dev
vim foundational/01-setup-jenkins.sh
git commit -m "fix: Improve setup script"
git push origin dev
```
→ **foundational-ci.yml** runs: Tests scripts

```bash
# 2. Merge to main (no publish/deploy for foundational)
git checkout main && git merge dev && git push
```
→ No production workflows run (foundational is for learning only)

#### Scenario 3: Deploy to EC2

```bash
# 1. Update docker01 application
git checkout dev
vim docker01/app.py
git commit -m "feat: Add new endpoint"
git push origin dev
```
→ Tests run (if configured)

```bash
# 2. Merge to main
git checkout main && git merge dev && git push
```
→ **docker-01-deploy.yml** runs: Deploys to EC2

## Manual Triggers

All workflows support manual dispatch:

### Trigger Foundational CI
```bash
gh workflow run foundational-ci.yml
```

### Trigger Jenkins Publish
```bash
gh workflow run docker-02-jenkins.yml
```

### Trigger EC2 Deploy
```bash
gh workflow run docker-01-deploy.yml
```

## Workflow Outputs

### Dev Branch (Test Phase)
- ✅ Build logs
- ✅ Test results
- ✅ Security scan reports
- ✅ Linting results
- ℹ️ Message: "Tests passed - merge to main to publish"

### Main Branch (Production Phase)
- ✅ Build logs
- ✅ Security scan results
- ✅ Published image details
- ✅ Docker Hub repository links
- ✅ Pull commands
- ✅ Deployment status (for EC2)

## Best Practices

### Do's ✅
- **Always test on dev first** before merging to main
- **Review security scans** before publishing
- **Use meaningful commit messages** to track changes
- **Create PRs** for code review
- **Test locally** before pushing
- **Monitor workflow runs** in GitHub Actions tab

### Don'ts ❌
- **Don't push directly to main** (except emergencies)
- **Don't skip tests** on dev branch
- **Don't ignore security warnings**
- **Don't publish untested images**
- **Don't merge failing PRs**

## Troubleshooting

### Workflow Not Triggering

**Check:**
1. Correct branch (dev or main)
2. Files changed are in trigger paths
3. Workflow file syntax is valid
4. No syntax errors in workflow YAML

**Fix:**
```bash
# Manually trigger
gh workflow run <workflow-name>.yml
```

### Tests Failing on Dev

**Check:**
1. Dockerfile syntax
2. Docker Compose file validity
3. Script permissions (`chmod +x`)
4. Required secrets are set

**Fix:**
- Review workflow logs
- Test locally: `docker build -t test .`
- Check error messages

### Publish Failing on Main

**Check:**
1. Docker Hub credentials (secrets)
2. Image builds successfully
3. No critical security issues
4. Sufficient Docker Hub quota

**Fix:**
- Verify secrets: `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- Check Docker Hub account status
- Review build logs

## Monitoring

### GitHub Actions Tab
- View all workflow runs
- Filter by branch, workflow, status
- Download logs and artifacts

### Security Tab
- View Trivy scan results
- SARIF upload status
- Vulnerability reports

### Docker Hub
- Verify published images
- Check image tags
- Monitor pull statistics

## Summary

| Phase | Branch | Workflows | Action | Result |
|-------|--------|-----------|--------|--------|
| **Testing** | dev | 3 CI workflows | Build & test | No publish |
| **Production** | main | 2 deploy workflows | Publish & deploy | Live updates |

**Key Principle:** Test everything on dev, publish only from main.

---

**Last Updated:** December 2024
**Maintained by:** redLUIT Team
**Repository:** https://github.com/redluit/redLUIT_Nov2025_Docker1234
