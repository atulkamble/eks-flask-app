import os
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "Hello from Flask on EKS!",
        "app": os.getenv("APP_NAME", "eks-flask-app"),
        "env": os.getenv("APP_ENV", "dev"),
        "version": os.getenv("APP_VERSION", "v0.1.0")
    })

@app.route("/health")
def health():
    return "ok", 200

@app.route("/api/echo", methods=["POST"])
def echo():
    payload = request.json or {}
    return jsonify({"echo": payload, "status": "received"}), 200

if __name__ == "__main__":
    # For local dev only; in container we use gunicorn
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
