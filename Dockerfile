FROM python:3.11-slim

WORKDIR /app
RUN adduser --disabled-password --gecos "" appuser

# Upgrade packaging/build tooling to patched versions (Trivy HIGH fixes)
RUN pip install --no-cache-dir --upgrade \
    pip \
    wheel==0.46.2 \
    jaraco.context==6.1.0

# Copy requirements first for caching
COPY App/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy app code
COPY App /app

USER appuser
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]