from fastapi.testclient import TestClient
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))  # adds App/ to sys.path
from main import app

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