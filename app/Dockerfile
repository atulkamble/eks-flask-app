# syntax=docker/dockerfile:1
FROM python:3.11-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends         ca-certificates curl &&         rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m appuser
WORKDIR /app

# Python deps
COPY src/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# App source
COPY src /app
ENV PORT=8080         APP_NAME=eks-flask-app         APP_ENV=dev         APP_VERSION=v0.1.0         PYTHONUNBUFFERED=1

EXPOSE 8080

USER appuser
# Use gunicorn in container
CMD ["gunicorn", "-b", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "wsgi:app"]
