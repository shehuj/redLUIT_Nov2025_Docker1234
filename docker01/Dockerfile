# Use a specific Ubuntu version to keep things stable
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and install Apache2
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove default html (optional) and add your custom webpage
COPY index.html /var/www/html/index.html

# Expose HTTP port
EXPOSE 80

# Run Apache in foreground so container keeps running
CMD ["apache2ctl", "-D", "FOREGROUND"]