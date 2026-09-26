from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)

# Allow frontend to communicate with Flask
CORS(app)


# Simple Flask test route
@app.route("/")
def root():
    return "Flask backend is running! Welcome to Assignment 6 - AWS Deployment!"


# GET request
@app.route("/api/hello", methods=["GET"])
def hello():

    return jsonify({
        "message": "Hello from Flask Backend! This is a Message from the backend server.",
        "status": "success"
    })


# POST request - receives data from frontend
@app.route("/api/data", methods=["POST"])
def receive_data():

    # Get JSON data sent by frontend
    data = request.get_json()

    # Get name from JSON
    name = data.get("name")

    # Send response back
    return jsonify({
        "message": f"Hello {name}!",
        "received_data": data
    })


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)