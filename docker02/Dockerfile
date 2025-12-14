# Start from official Jenkins LTS base
FROM jenkins/jenkins:lts

# Switch to root to install additional packages
USER root

# Example: install basic tools
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    && apt-get clean

# Optional: preinstall Jenkins plugins via plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN [ -f /usr/share/jenkins/ref/plugins.txt ] && \
    jenkins-plugin-cli --plugins < /usr/share/jenkins/ref/plugins.txt || true

# Switch back to Jenkins user
USER jenkins