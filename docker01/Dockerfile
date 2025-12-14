FROM ubuntu:24.04

# Prevent prompts during install
## ARG DEBIAN_FRONTEND=noninteractive

# Update and install Apache
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy custom webpage
COPY index.html /var/www/html/index.html

# Optional: set ownership so Apache can serve correctly
RUN chown www-data:www-data /var/www/html/index.html

# Expose HTTP port
EXPOSE 80

# Run Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]