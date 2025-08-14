# Flask Application (Containerized)

## Local Dev
```bash
cd app
python3 -m venv .venv && source .venv/bin/activate
pip install -r src/requirements.txt
python src/app.py
# open http://127.0.0.1:8080
```

## Build & Run Docker Locally
```bash
cd app
docker build -t eks-flask-app:local .
docker run --rm -p 8080:8080 -e APP_ENV=local eks-flask-app:local
```
