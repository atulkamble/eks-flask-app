import os
from flask import Flask, jsonify, request, render_template, send_from_directory

# Tell Flask where templates/static live
app = Flask(__name__, template_folder="templates", static_folder="static")

@app.route("/")
def home_json():
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

# New: simple UI
@app.route("/ui")
def ui():
    return render_template("index.html")

if __name__ == "__main__":
    # local dev convenience
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
