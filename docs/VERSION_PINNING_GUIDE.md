# Version Pinning Strategy Guide

This guide explains our version pinning strategy and the trade-offs involved.

## Philosophy

We balance **reproducibility** with **maintainability** and **security**.

## Version Pinning Strategies

### 1. No Pinning (Not Recommended)

```dockerfile
RUN pip3 install ansible boto3
```

**Pros:**
- Always gets latest versions
- Automatic security updates

**Cons:**
- ❌ Unpredictable builds
- ❌ Breaking changes possible
- ❌ Hard to debug issues
- ❌ Fails Hadolint DL3013

**Use when:** Never in production

---

### 2. Exact Pinning (Problematic)

```dockerfile
RUN pip3 install ansible==9.1.0 boto3==1.34.27
```

**Pros:**
- ✅ Highly reproducible
- ✅ Predictable builds

**Cons:**
- ❌ No security updates
- ❌ Version conflicts with dependencies
- ❌ Packages may be removed from repos
- ❌ Requires frequent manual updates
- ❌ **Builds break when versions unavailable**

**Use when:** You need exact reproducibility (e.g., research, compliance)

**Our experience:**
```
ERROR: Could not find a version that satisfies the requirement ansible==9.1.0
```
This happened because exact versions become unavailable over time.

---

### 3. Minimum Version Constraints (Recommended) ⭐

```dockerfile
RUN pip3 install --no-cache-dir \
    'ansible>=9.0.0' \
    'boto3>=1.34.0' \
    'botocore>=1.34.0'
```

**Pros:**
- ✅ Ensures minimum required version
- ✅ Gets compatible updates
- ✅ Security patches included
- ✅ Satisfies Hadolint DL3013
- ✅ More resilient to repo changes
- ✅ Balance between stability and updates

**Cons:**
- ⚠️ Slightly less reproducible
- ⚠️ May get breaking changes in major updates

**Use when:** Most production scenarios (our default)

---

### 4. Compatible Version Constraints (Also Good)

```dockerfile
RUN pip3 install --no-cache-dir \
    'ansible~=9.1.0' \
    'boto3~=1.34.0'
```

**Equivalents:**
- `~=9.1.0` means `>=9.1.0, <9.2.0`
- Gets patch updates, not minor updates

**Pros:**
- ✅ Gets security patches
- ✅ No breaking changes (follows SemVer)
- ✅ More predictable than `>=`

**Cons:**
- ⚠️ Still requires periodic updates

**Use when:** You need stability but want security patches

---

### 5. Upper Bounded Constraints

```dockerfile
RUN pip3 install --no-cache-dir \
    'ansible>=9.0.0,<10.0.0' \
    'boto3>=1.34.0,<2.0.0'
```

**Pros:**
- ✅ Prevents major version updates
- ✅ Gets minor/patch updates
- ✅ Good for CI/CD

**Cons:**
- ⚠️ More complex syntax
- ⚠️ Requires version knowledge

**Use when:** You want updates but avoid major version changes

---

## Our Choice: Minimum Version Constraints

We use `>=` for these reasons:

1. **Practical**: Doesn't break when exact versions are removed
2. **Secure**: Gets security updates automatically
3. **Maintainable**: Less frequent manual updates needed
4. **Compatible**: Works with dependency resolution
5. **Hadolint**: Satisfies DL3013 warning

### Example from Our Dockerfile

```dockerfile
# Install Python packages with flexible version constraints
# Using >= to allow compatible updates while maintaining minimum versions
# --break-system-packages is needed for PEP 668 compliance
RUN pip3 install --no-cache-dir --break-system-packages \
    'ansible>=9.0.0' \
    'boto3>=1.34.0' \
    'botocore>=1.34.0'
```

### PEP 668: Externally Managed Environments

Modern Python installations (Debian 12+, Ubuntu 23.04+) are "externally managed" per [PEP 668](https://peps.python.org/pep-0668/). This prevents pip from modifying system Python packages.

**Error you'll see:**
```
error: externally-managed-environment
× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

**Solutions:**

1. **Use `--break-system-packages`** (Recommended for Docker):
   ```dockerfile
   RUN pip3 install --break-system-packages 'ansible>=9.0.0'
   ```
   - ✅ Safe in containers (we control everything)
   - ✅ Simple and direct
   - ⚠️ Don't use on host systems

2. **Use virtual environment**:
   ```dockerfile
   RUN python3 -m venv /opt/venv
   ENV PATH="/opt/venv/bin:$PATH"
   RUN pip install 'ansible>=9.0.0'
   ```
   - ✅ Isolated environment
   - ⚠️ More complex
   - ⚠️ Larger image size

3. **User installation**:
   ```dockerfile
   RUN pip3 install --user 'ansible>=9.0.0'
   ```
   - ✅ Respects PEP 668
   - ⚠️ Path issues
   - ⚠️ User-specific location

## Why We Don't Pin apt Packages

For system packages via `apt-get`, we **don't pin versions**:

```dockerfile
# We do this:
RUN apt-get install -y --no-install-recommends git curl

# Not this:
RUN apt-get install -y git=1:2.34.1-1ubuntu1.8
```

**Reasons:**
1. Package versions change between OS releases
2. Security updates are critical
3. Base image handles version stability
4. Pinning makes Dockerfile non-portable
5. Debian/Ubuntu package versions are complex

See `.hadolint.yaml` for DL3008 ignore rationale.

## Version Update Strategy

### When to Update Versions

1. **Security advisories**: Immediately
2. **Quarterly**: Review and update minimums
3. **Before releases**: Test with latest versions
4. **Breaking changes**: Pin if needed temporarily

### How to Update

```bash
# Check current versions in container
docker run jenkins-custom-complex:latest pip3 list

# Update Dockerfile with new minimums
# Test build
docker build -t test .

# Run tests
docker run test python3 -c "import ansible; print(ansible.__version__)"
```

## Testing Strategy

### 1. Local Testing

```bash
# Build with current constraints
docker build -t jenkins-custom:test .

# Verify package versions
docker run jenkins-custom:test pip3 list | grep -E "ansible|boto"

# Test functionality
docker run jenkins-custom:test python3 -c "import ansible, boto3"
```

### 2. CI/CD Testing

Our workflows test with:
- Latest package versions (via `>=`)
- Multiple Python versions (if needed)
- Integration tests

### 3. Lock Files (Future Enhancement)

Consider adding `requirements.txt`:

```txt
# requirements.txt
ansible>=9.0.0
boto3>=1.34.0
botocore>=1.34.0
```

Then:
```dockerfile
COPY requirements.txt /tmp/
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt
```

## Comparison Table

| Strategy | Reproducibility | Security | Maintainability | Our Rating |
|----------|----------------|----------|-----------------|------------|
| No pinning | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ❌ |
| Exact (`==`) | ⭐⭐⭐⭐⭐ | ⭐ | ⭐ | ⚠️ |
| Minimum (`>=`) | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ |
| Compatible (`~=`) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ |
| Bounded range | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ✅ |

## Troubleshooting

### Build Fails: Package Not Found

```
ERROR: Could not find a version that satisfies the requirement ansible==9.1.0
```

**Solution**: Use minimum constraints instead
```dockerfile
RUN pip3 install 'ansible>=9.0.0'
```

### Dependency Conflicts

```
ERROR: Cannot install ansible 9.0.0 and boto3 1.34.0 because these package versions have conflicting dependencies
```

**Solution**: Let pip resolve dependencies
```dockerfile
# Let pip resolve compatible versions
RUN pip3 install 'ansible>=9.0.0' 'boto3>=1.34.0'
```

### Want Exact Reproducibility

**Solution**: Use lock file or multi-stage build
```dockerfile
# Stage 1: Resolve and lock
FROM python:3.11 as resolver
RUN pip install ansible boto3
RUN pip freeze > /requirements.lock

# Stage 2: Install from lock
FROM jenkins/jenkins:lts
COPY --from=resolver /requirements.lock /tmp/
RUN pip3 install -r /tmp/requirements.lock
```

## Best Practices Summary

✅ **Do:**
- Use minimum version constraints (`>=`)
- Document why you chose specific versions
- Test builds regularly
- Update constraints quarterly
- Use lock files for critical deployments

❌ **Don't:**
- Use no version constraints in production
- Pin exact versions unless absolutely necessary
- Ignore security updates
- Mix version strategies randomly

## Resources

- [PEP 440 - Version Specifiers](https://peps.python.org/pep-0440/)
- [pip Requirements File Format](https://pip.pypa.io/en/stable/reference/requirements-file-format/)
- [Semantic Versioning](https://semver.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Last Updated**: December 2024
**Status**: Active
**Strategy**: Minimum Version Constraints (`>=`)
