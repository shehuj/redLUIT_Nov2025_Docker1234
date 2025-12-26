# Custom Jenkins Dockerfile for Complex Level
# This Dockerfile creates a customized Jenkins image with pre-installed tools and plugins

FROM jenkins/jenkins:lts

# Metadata
LABEL maintainer="redLUIT Team"
LABEL description="Custom Jenkins image with pre-configured tools and plugins"
LABEL version="1.0"

# Switch to root user for system package installation
USER root

# Install system dependencies with best practices
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    curl \
    ansible \
    unzip \
    python3 \
    python3-pip \
    docker.io \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install kubectl for Kubernetes deployments
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Terraform using curl
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Install Python packages with flexible version constraints
# Using >= to allow compatible updates while maintaining minimum versions
# --break-system-packages is needed for PEP 668 compliance in containerized environments
RUN pip3 install --no-cache-dir --break-system-packages \
    'ansible>=9.0.0' \
    'boto3>=1.34.0' \
    'botocore>=1.34.0'

# Copy plugins list and install essential Jenkins plugins
# Using minimal plugin set for reliability - add more plugins via Jenkins UI after deployment
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy custom Jenkins configuration (if any)
COPY --chown=jenkins:jenkins jenkins.yaml /var/jenkins_home/casc_jenkins.yaml

# Set environment variables
ENV JENKINS_HOME=/var/jenkins_home
ENV JAVA_OPTS="-Djava.awt.headless=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York"
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_jenkins.yaml

# Create necessary directories
RUN mkdir -p /var/jenkins_home/workspace \
    && mkdir -p /var/jenkins_home/jobs \
    && chown -R jenkins:jenkins /var/jenkins_home

# Expose ports
EXPOSE 8080 50000

# Switch back to Jenkins user
USER jenkins

# Set working directory
WORKDIR /var/jenkins_home

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8080/login || exit 1

# Entry point
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
