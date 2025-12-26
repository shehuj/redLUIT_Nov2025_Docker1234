# Jenkins Configuration as Code (CasC)

This guide explains how Configuration as Code works in our custom Jenkins image.

## Overview

Configuration as Code (CasC) allows you to define Jenkins configuration in YAML files instead of using the UI. Our image includes a minimal CasC configuration that won't interfere with the setup wizard.

## Current Configuration

### Minimal Setup (`complex/jenkins.yaml`)

```yaml
jenkins:
  systemMessage: "Jenkins configured using Configuration as Code (CasC) - redLUIT Project"
  numExecutors: 2
  mode: NORMAL

unclassified:
  location:
    url: "http://localhost:8080/"
    adminAddress: "jenkins@localhost"

tool:
  git:
    installations:
      - name: "Default"
        home: "git"
```

**What this does:**
- Sets a system message
- Configures 2 executors
- Sets Jenkins URL and admin email
- Configures Git tool

**What it doesn't do:**
- ❌ Skip setup wizard (you'll see it on first run)
- ❌ Configure security (you choose during setup)
- ❌ Create default users
- ❌ Create jobs

## Why Minimal Configuration?

### The Problem with Complex CasC

Complex CasC configurations can cause Jenkins to crash if:
- Referenced plugins aren't installed
- Tool installers aren't available
- Job DSL syntax has errors
- Security configuration conflicts with setup wizard

**Example of problematic config:**
```yaml
# DON'T DO THIS without required plugins
jenkins:
  securityRealm:
    local:
      users:
        - id: "admin"
          password: "admin123"  # Requires specific plugin

tool:
  maven:
    installations:
      - properties:
          - installSource:
              installers:
                - maven:
                    id: "3.9.6"  # May not be available

jobs:
  - script: >
      pipelineJob('test') { ... }  # Requires job-dsl plugin
```

### Our Approach

✅ **Minimal + Setup Wizard**:
- Minimal CasC for basic settings
- Setup wizard for security and plugins
- User configures what they need
- No startup crashes

## First Run Experience

### 1. Container Starts
```bash
docker run -d -p 8080:8080 jenkins-custom-complex:latest
```

### 2. Access Jenkins
Open http://localhost:8080

### 3. Setup Wizard Appears
You'll see:
1. **Unlock Jenkins** - Get password from container
2. **Customize Jenkins** - Install plugins
3. **Create First Admin User**
4. **Instance Configuration** - Confirm URL

### 4. CasC Takes Effect
After setup, you'll see:
- System message from CasC
- 2 executors configured
- Git tool pre-configured

## Extending CasC Configuration

### Method 1: Edit jenkins.yaml and Rebuild

Edit `complex/jenkins.yaml`:

```yaml
jenkins:
  systemMessage: "My Custom Jenkins"
  numExecutors: 4  # Increase executors

  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "myuser"
          password: "${ADMIN_PASSWORD}"  # Use environment variable

unclassified:
  location:
    url: "https://jenkins.example.com/"
    adminAddress: "admin@example.com"

  # Add more plugin configurations here
```

Then rebuild:
```bash
cd complex
./01-build-image.sh
```

### Method 2: Mount External Config

Don't rebuild - mount config at runtime:

```bash
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/my-jenkins.yaml:/var/jenkins_home/casc_jenkins.yaml \
  jenkins-custom-complex:latest
```

### Method 3: Use Jenkins UI

Configure via UI, then export:
1. Go to **Manage Jenkins** → **Configuration as Code**
2. Click **View Configuration**
3. Copy the YAML
4. Save to file for future use

## Common CasC Configurations

### Basic Security

```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "${JENKINS_ADMIN_PASSWORD}"

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
```

**Note**: Requires environment variable `JENKINS_ADMIN_PASSWORD`

### GitHub Integration

```yaml
unclassified:
  githubPluginConfig:
    configs:
      - name: "GitHub"
        apiUrl: "https://api.github.com"
        credentialsId: "github-token"
```

**Requires**: github plugin installed

### Docker Configuration

```yaml
unclassified:
  docker:
    dockerHostUri: "unix:///var/run/docker.sock"
```

**Requires**: docker-workflow plugin

### Email Notifications

```yaml
unclassified:
  mailer:
    smtpHost: "smtp.example.com"
    smtpPort: "587"
    useSsl: true
    smtpAuth:
      username: "jenkins@example.com"
      password: "${EMAIL_PASSWORD}"
```

## Environment Variables

Use environment variables for secrets:

```yaml
jenkins:
  systemMessage: "Welcome ${USER_NAME}!"
```

Pass at runtime:
```bash
docker run -d \
  -e USER_NAME="John" \
  -e EMAIL_PASSWORD="secret" \
  jenkins-custom-complex:latest
```

## Troubleshooting

### Jenkins Won't Start

**Check logs:**
```bash
docker logs jenkins_complex 2>&1 | grep -i casc
```

**Common issues:**
- Invalid YAML syntax
- Missing required plugins
- Referenced credentials don't exist
- Tool installers not available

**Solution**: Simplify jenkins.yaml or remove it temporarily

### CasC Not Applied

**Verify CasC is loaded:**
1. Go to **Manage Jenkins** → **Configuration as Code**
2. Check if config appears
3. Click **Reload existing configuration**

**Check file location:**
```bash
docker exec jenkins_complex ls -la /var/jenkins_home/casc_jenkins.yaml
```

### Security Configuration Fails

If security config in CasC fails:
1. Remove security section from yaml
2. Restart Jenkins
3. Configure security via UI
4. Export working config from UI

## Skip Setup Wizard (Advanced)

To skip the setup wizard entirely:

**1. Update Dockerfile:**
```dockerfile
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false ..."
```

**2. Complete CasC config:**
```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "admin"
          password: "${JENKINS_ADMIN_PASSWORD}"

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
```

**3. Set environment variable:**
```bash
docker run -d \
  -e JENKINS_ADMIN_PASSWORD="your-secure-password" \
  jenkins-custom-complex:latest
```

⚠️ **Warning**: Only do this if you have a complete, tested CasC configuration!

## Best Practices

### ✅ Do:
- Start with minimal config
- Test configs locally before deploying
- Use environment variables for secrets
- Document your configurations
- Keep CasC files in version control
- Export working configs from UI

### ❌ Don't:
- Put passwords directly in YAML
- Reference non-existent plugins
- Skip testing complex configs
- Disable setup wizard without complete config
- Ignore CasC validation errors

## Validation

Validate CasC before deploying:

```bash
# Build and test locally
docker build -t jenkins-test .
docker run -d --name jenkins-test jenkins-test

# Check logs for CasC errors
docker logs jenkins-test 2>&1 | grep -i casc

# If successful, tag and deploy
docker tag jenkins-test jenkins-custom-complex:latest
```

## Resources

- [JCasC Plugin Documentation](https://github.com/jenkinsci/configuration-as-code-plugin)
- [JCasC Examples](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos)
- [Jenkins Documentation](https://www.jenkins.io/doc/book/managing/casc/)
- [CasC Schema](https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/secrets.md)

---

**Current Approach**: Minimal CasC + Setup Wizard
**Rationale**: Reliability and flexibility
**Security**: Configure via setup wizard
**Expandability**: Add configs as needed
