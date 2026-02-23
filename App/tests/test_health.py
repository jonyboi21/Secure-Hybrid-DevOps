from __future__ import annotations

import sys
from pathlib import Path

from fastapi.testclient import TestClient

# Ensure App/ is importable when tests run from repo root in CI
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from main import app  # noqa: E402

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_version():
    r = client.get("/version")
    assert r.status_code == 200
    body = r.json()
    assert "app" in body and "version" in body