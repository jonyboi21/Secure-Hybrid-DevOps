FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser

# Pin/upgrade Python packaging toolchain to versions that include the fixes
RUN python -m pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel==0.46.2 \
    jaraco.context==6.1.0

# Copy requirements first (better layer caching)
COPY App/requirements.txt /app/requirements.txt

# Install app dependencies
RUN python -m pip install --no-cache-dir -r /app/requirements.txt

# Sanity check (helps confirm what Trivy should see)
RUN python -m pip show wheel jaraco.context

# Copy application source
COPY App /app

USER appuser
EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]