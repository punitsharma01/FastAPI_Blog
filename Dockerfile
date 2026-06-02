# --- BUILD STAGE ---
FROM python:3.11-slim-bookworm AS builder

# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies (if any of your requirements need to compile C extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies into a local directory to be copied later
# Using --user installs into /root/.local/bin and /root/.local/lib
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# --- PRODUCTION STAGE ---
FROM python:3.11-slim-bookworm

WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/home/appuser/.local/bin:$PATH"
ENV PORT=8080

# Run as non-root user for security
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Copy installed dependencies from builder stage
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser . .

# Metadata and execution
EXPOSE 8080

# Use exec to ensure signals (like SIGTERM) reach FastAPI directly
CMD ["sh", "-c", "exec fastapi run --host 0.0.0.0 --port \"$PORT\" --proxy-headers --forwarded-allow-ips '*'"]