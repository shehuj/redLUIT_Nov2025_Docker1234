# Jenkins Plugin Management

This guide explains how Jenkins plugins are managed in our custom Docker image.

## Pre-installed Plugins

We pre-install a minimal set of **essential plugins** for reliability:

```
workflow-aggregator      # Pipeline functionality
pipeline-stage-view      # Pipeline visualization
git                      # Git integration
github                   # GitHub integration
configuration-as-code    # JCasC support
timestamper             # Timestamps in logs
```

## Why Minimal Plugin Set?

1. **Build Reliability**: Fewer plugins = fewer dependency conflicts
2. **Faster Builds**: Less time downloading and installing
3. **Smaller Image**: Reduced Docker image size
4. **Flexibility**: Users choose what they need
5. **Updates**: Plugins update via Jenkins UI

## Adding More Plugins

### Method 1: Jenkins Web UI (Recommended)

1. Access Jenkins at `http://localhost:8080`
2. Go to **Manage Jenkins** → **Plugins**
3. Click **Available plugins** tab
4. Search for desired plugins
5. Select checkboxes and click **Install**
6. Restart Jenkins when prompted

**Popular plugins to add:**
- Docker Pipeline
- Kubernetes
- Ansible
- Blue Ocean (modern UI)
- Email Extension
- Slack Notification
- SonarQube Scanner
- JUnit
- Warnings Next Generation

### Method 2: Update plugins.txt and Rebuild

Edit `complex/plugins.txt`:

```txt
# Essential workflow plugins
workflow-aggregator
pipeline-stage-view

# Git integration
git
github

# Configuration as Code
configuration-as-code

# Utilities
timestamper

# ADD YOUR PLUGINS HERE
docker-workflow
kubernetes
blue-ocean
email-ext
```

Then rebuild the image:

```bash
cd complex
./01-build-image.sh
```

### Method 3: Jenkins CLI

```bash
# SSH into running container
docker exec -it jenkins_complex bash

# Install plugin
jenkins-plugin-cli --plugins docker-workflow kubernetes

# Restart Jenkins
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ safe-restart
```

### Method 4: Configuration as Code (JCasC)

Edit `complex/jenkins.yaml`:

```yaml
jenkins:
  # ... existing config ...

tool:
  # ... existing tools ...

plugins:
  required:
    - docker-workflow
    - kubernetes
    - blue-ocean
```

Note: JCasC plugin installation support is limited. Use Method 1 or 2 instead.

## Plugin Dependencies

Jenkins automatically resolves plugin dependencies. When you install a plugin, it will:

1. ✅ Download the plugin
2. ✅ Download required dependencies
3. ✅ Prompt for restart if needed

## Troubleshooting

### Plugin Installation Fails During Build

**Error:**
```
ERROR: Error downloading plugin: [plugin-name]
```

**Solutions:**

1. **Remove problematic plugin** from `plugins.txt`
2. **Check plugin ID** at https://plugins.jenkins.io/
3. **Install via UI** after deployment instead
4. **Check network connectivity** during build

### Plugin Doesn't Work After Install

```bash
# Check Jenkins logs
docker logs jenkins_complex

# Look for plugin errors
docker logs jenkins_complex 2>&1 | grep -i error
```

**Common issues:**
- Missing dependencies (should auto-install)
- Java version incompatibility
- Plugin conflicts
- Requires Jenkins restart

### Can't Find Plugin

Search the **Jenkins Plugin Index**:
- https://plugins.jenkins.io/

Find the correct **plugin ID** (not display name):
```
Display Name: "Docker Pipeline"
Plugin ID: "docker-workflow"  ← Use this in plugins.txt
```

## Plugin Versions

### Latest Version (Recommended)

```txt
# Gets latest version automatically
docker-workflow
```

### Specific Version

```txt
# Pin to specific version
docker-workflow:572.v950f58993843
git:5.5.2
```

**When to pin:**
- Production environments
- Known working configuration
- Avoid breaking changes

**When to use latest:**
- Development
- Want new features
- Get security updates

## Pre-install vs. Post-install

| Aspect | Pre-install (plugins.txt) | Post-install (UI) |
|--------|---------------------------|-------------------|
| **Timing** | During image build | After deployment |
| **Rebuild Required** | ✅ Yes | ❌ No |
| **Good For** | Essential plugins | Optional plugins |
| **Persistence** | ✅ In image | ⚠️ In volume |
| **Updates** | Rebuild image | Update in UI |

## Backup Plugins

### Export Plugin List

```bash
# Get list of installed plugins
docker exec jenkins_complex jenkins-plugin-cli --list > installed-plugins.txt
```

### Import Plugin List

```bash
# Install from list
docker exec jenkins_complex jenkins-plugin-cli --plugin-file /tmp/installed-plugins.txt
```

## Common Plugin Sets

### Minimal (Pre-installed)

```txt
workflow-aggregator
git
configuration-as-code
```

### Basic CI/CD

```txt
workflow-aggregator
pipeline-stage-view
git
github
junit
email-ext
timestamper
```

### Docker/Kubernetes

```txt
workflow-aggregator
git
docker-workflow
kubernetes
configuration-as-code
```

### Full DevOps

```txt
workflow-aggregator
pipeline-stage-view
git
github
docker-workflow
kubernetes
ansible
blue-ocean
email-ext
slack
sonarqube-scanner
junit
warnings-ng
configuration-as-code
job-dsl
timestamper
```

## Plugin Update Strategy

### Regular Updates

1. **Backup Jenkins** first:
   ```bash
   docker exec jenkins_complex tar czf /var/jenkins_backup/backup.tar.gz -C /var/jenkins_home .
   ```

2. **Update plugins** via UI:
   - Manage Jenkins → Plugins → Updates
   - Select all or specific plugins
   - Click "Download now and install after restart"

3. **Test** after restart

### Automated Updates (Not Recommended for Production)

Enable in Jenkins:
- Manage Jenkins → Configure System
- Check "Install updates automatically"

⚠️ **Risk**: May introduce breaking changes

## Security

### Plugin Security Advisories

Check for security issues:
- https://www.jenkins.io/security/advisories/

Update affected plugins immediately.

### Plugin Permissions

Some plugins require:
- File system access
- Network access
- Execute permissions

Review permissions before installing.

## Performance

### Too Many Plugins

Symptoms:
- Slow Jenkins startup
- High memory usage
- UI sluggishness

**Solution**: Remove unused plugins

### Check Plugin Usage

```bash
# See what plugins are actually used
docker exec jenkins_complex java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ list-plugins
```

## Best Practices

✅ **Do:**
- Start with minimal plugins
- Add plugins as needed
- Keep plugins updated
- Backup before major updates
- Test in dev environment first
- Document required plugins

❌ **Don't:**
- Install every plugin
- Ignore security updates
- Skip backups before updates
- Mix incompatible plugin versions
- Forget to restart after installation

## Resources

- [Jenkins Plugin Index](https://plugins.jenkins.io/)
- [Plugin Tutorial](https://www.jenkins.io/doc/book/managing/plugins/)
- [Plugin Development](https://www.jenkins.io/doc/developer/plugin-development/)
- [Security Advisories](https://www.jenkins.io/security/advisories/)

---

**Last Updated**: December 2024
**Default Plugins**: 6 essential plugins
**Installation Method**: jenkins-plugin-cli
