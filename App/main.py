from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os
import time

APP_NAME = os.getenv("APP_NAME", "secure-hybrid-devops")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")

app = FastAPI(title=APP_NAME, version=APP_VERSION)

REQUESTS = Counter("http_requests_total", "Total HTTP requests", ["path", "method", "status"])
LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["path", "method"])

@app.middleware("http")
async def metrics_middleware(request, call_next):
    path = request.url.path
    method = request.method
    start = time.time()
    try:
        response = await call_next(request)
        status = str(response.status_code)
        return response
    finally:
        dur = time.time() - start
        LATENCY.labels(path=path, method=method).observe(dur)
        # If response failed before assignment, treat as 500
        status = locals().get("status", "500")
        REQUESTS.labels(path=path, method=method, status=status).inc()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/version")
def version():
    return {"app": APP_NAME, "version": APP_VERSION}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return PlainTextResponse(content=data.decode("utf-8"), media_type=CONTENT_TYPE_LATEST)