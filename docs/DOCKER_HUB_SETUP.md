# Docker Hub Setup Guide

This guide helps you set up Docker Hub for automatic image publishing.

## Prerequisites

- Docker Hub account (free tier is sufficient)
- Access to GitHub repository settings

## Step 1: Create Docker Hub Access Token

1. **Go to Docker Hub Security Settings**
   - Visit: https://hub.docker.com/settings/security
   - Log in if needed

2. **Create New Access Token**
   - Click **New Access Token**
   - **Description:** `GitHub Actions - redLUIT_Nov2025_Docker1234`
   - **Permissions:** Select **Read, Write, Delete**
   - Click **Generate**

3. **Copy Token**
   - ⚠️ **IMPORTANT:** Copy the token immediately
   - You won't be able to see it again!
   - Save it temporarily in a secure location

## Step 2: Create Docker Hub Repository

The repository must exist before the workflow can push to it.

### Option A: Create via Web UI (Recommended)

1. **Go to Docker Hub Repositories**
   - Visit: https://hub.docker.com/repository/create

2. **Create Repository**
   - **Name:** `jenkins-custom`
   - **Description:** Production-grade Jenkins with DevOps tools
   - **Visibility:**
     - **Public** (recommended) - Free tier allows unlimited public repos
     - **Private** - Requires paid plan
   - Click **Create**

3. **Verify Creation**
   - Your repository will be at: `https://hub.docker.com/r/<your-username>/jenkins-custom`

### Option B: Create via Docker CLI

```bash
# Login to Docker Hub
docker login

# Create and push a dummy tag to create the repository
docker pull hello-world
docker tag hello-world:latest <your-username>/jenkins-custom:init
docker push <your-username>/jenkins-custom:init

# Clean up
docker rmi <your-username>/jenkins-custom:init
```

## Step 3: Add Secrets to GitHub

1. **Go to Repository Settings**
   - Navigate to: `https://github.com/<your-org>/redLUIT_Nov2025_Docker1234/settings/secrets/actions`
   - Or: Repository → Settings → Secrets and variables → Actions

2. **Add DOCKER_USERNAME**
   - Click **New repository secret**
   - **Name:** `DOCKER_USERNAME`
   - **Value:** Your Docker Hub username (e.g., `redluit`)
   - Click **Add secret**

3. **Add DOCKER_PASSWORD**
   - Click **New repository secret**
   - **Name:** `DOCKER_PASSWORD`
   - **Value:** Paste the access token from Step 1
   - Click **Add secret**

## Step 4: Verify Setup

### Test Docker Hub Login Locally

```bash
# Use the same credentials as in GitHub secrets
docker login -u <your-username> -p <your-token>

# Should see: Login Succeeded
```

### Test Repository Push Locally

```bash
# Build test image
cd complex
docker build -t <your-username>/jenkins-custom:test .

# Push to verify access
docker push <your-username>/jenkins-custom:test

# Should succeed without errors
```

### Trigger GitHub Workflow

```bash
# Make a small change to complex/
echo "# Updated $(date)" >> complex/README.md
git add complex/README.md
git commit -m "test: Trigger Docker Hub publish"

# Push to dev first (test only)
git push origin dev

# Merge to main (publish)
git checkout main
git merge dev
git push origin main
```

Watch the workflow at: `https://github.com/<your-org>/redLUIT_Nov2025_Docker1234/actions`

## Troubleshooting

### Error: "push access denied"

**Cause:** Repository doesn't exist or credentials are wrong

**Solution:**
1. Create repository on Docker Hub (Step 2)
2. Verify secrets are correct (Step 3)
3. Check access token has write permissions

### Error: "insufficient_scope"

**Cause:** Access token doesn't have write permissions

**Solution:**
1. Create new access token with **Read, Write, Delete** permissions
2. Update `DOCKER_PASSWORD` secret in GitHub

### Error: "authentication required"

**Cause:** Secrets not set or incorrect

**Solution:**
1. Verify secrets exist:
   ```bash
   gh secret list
   ```
2. Check secret values are correct
3. Recreate secrets if needed

### Error: "repository name must be lowercase"

**Cause:** Repository name has uppercase letters

**Solution:**
- Repository name must be: `jenkins-custom` (all lowercase)
- Username can be any case: `redLUIT` or `redluit`

## Verification Checklist

Before pushing to main, verify:

- [ ] Docker Hub account created
- [ ] Access token created with write permissions
- [ ] Repository `jenkins-custom` created on Docker Hub
- [ ] `DOCKER_USERNAME` secret added to GitHub
- [ ] `DOCKER_PASSWORD` secret added to GitHub
- [ ] Tested locally: `docker push <username>/jenkins-custom:test`
- [ ] Workflow file updated with correct repository name

## Security Best Practices

### Access Token

- ✅ Use access tokens, not passwords
- ✅ Create token with minimal required permissions
- ✅ Name token descriptively (e.g., "GitHub Actions - Repo X")
- ✅ Rotate tokens every 90 days
- ❌ Never commit tokens to git
- ❌ Don't share tokens via email/chat

### GitHub Secrets

- ✅ Use repository secrets for single repo
- ✅ Use organization secrets for multiple repos
- ✅ Review secret access logs periodically
- ❌ Don't print secrets in workflow logs
- ❌ Don't expose secrets in pull requests from forks

### Docker Hub Repository

- ✅ Use public repos for open source
- ✅ Enable vulnerability scanning
- ✅ Review security scan results
- ✅ Keep base images updated
- ❌ Don't store secrets in images
- ❌ Don't use `:latest` in production

## Repository Settings

### Recommended Docker Hub Settings

1. **Description**
   ```
   Production-grade Jenkins with pre-installed DevOps tools
   (Docker, kubectl, Terraform, Ansible)
   ```

2. **README** (will be auto-updated from Dockerfile labels)
   - Automatically populated from image labels
   - Or create custom README on Docker Hub

3. **Visibility**
   - **Public:** Free, unlimited pulls
   - **Private:** Requires paid plan, limited pulls

4. **Automated Builds**
   - Not needed (using GitHub Actions instead)
   - Can be disabled

## Multi-Platform Builds

The workflow builds for both amd64 and arm64:

```yaml
platforms: linux/amd64,linux/arm64
```

**Supported Platforms:**
- `linux/amd64` - Intel/AMD x86_64 (most servers, desktop)
- `linux/arm64` - ARM 64-bit (Apple M1/M2, AWS Graviton)

**To disable arm64:**
```yaml
platforms: linux/amd64
```

## Monitoring

### Docker Hub Dashboard

- **Pulls:** Monitor download statistics
- **Stars:** Track repository popularity
- **Tags:** View all published versions
- **Security:** Check vulnerability scan results

### GitHub Actions

- **Workflow runs:** Monitor build/push success
- **Logs:** Debug any failures
- **Artifacts:** Download SARIF security reports

## Cost Considerations

### Docker Hub Free Tier

- ✅ Unlimited public repositories
- ✅ Unlimited public image pulls
- ✅ 1 private repository
- ⚠️ Rate limits: 100 pulls per 6 hours (anonymous), 200 pulls (authenticated)

### GitHub Actions

- ✅ Free for public repositories
- ✅ 2,000 minutes/month for private repos (free tier)
- ⚠️ Linux runners count as 1x minutes
- ⚠️ Multi-platform builds use more minutes

## Additional Resources

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [GitHub Actions Docker publish](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Login Action](https://github.com/docker/login-action)

## Quick Reference

### Docker Hub URLs

| Resource | URL |
|----------|-----|
| Create Token | https://hub.docker.com/settings/security |
| Create Repository | https://hub.docker.com/repository/create |
| Your Repositories | https://hub.docker.com/repositories |
| Security Scans | https://hub.docker.com/repository/docker/{username}/jenkins-custom/tags |

### GitHub URLs

| Resource | URL |
|----------|-----|
| Actions Secrets | Settings → Secrets and variables → Actions |
| Workflow Runs | Actions tab |
| Security Alerts | Security → Code scanning |

### Commands

```bash
# Login to Docker Hub
docker login -u <username>

# Pull your image
docker pull <username>/jenkins-custom:latest

# Check image details
docker inspect <username>/jenkins-custom:latest

# View image history
docker history <username>/jenkins-custom:latest
```

---

**Last Updated:** December 2024
**For Repository:** redLUIT_Nov2025_Docker1234
**Workflow:** docker-02-jenkins.yml
