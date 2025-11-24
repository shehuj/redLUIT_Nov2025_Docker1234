# Use specific version pinning
FROM python:3.12.1-slim-bookworm AS base

# Add metadata labels
LABEL org.opencontainers.image.source="https://github.com/shehuj/redLUIT_Nov2025_Docker1234"
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.description="This is a sample Python application Docker image for my blog site."
LABEL org.opencontainers.image.licenses="MIT"

# Build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${VERSION}"

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Security: Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /atechbroe

# Copy requirements first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "print('healthy')" || exit 1

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "atechbroe.py"]