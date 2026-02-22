# syntax=docker/dockerfile:1.7
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser

# Install deps first for caching
COPY App/requirements.txt /App/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY app /app/app

USER appuser
EXPOSE 8080

# Uvicorn server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]