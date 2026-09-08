from flask import Flask, request, jsonify
import pymongo
from dotenv import load_dotenv
import os

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")

client = pymongo.MongoClient(MONGO_URI)

db = client.flask
collection = db["flask_Tutorial"]


app = Flask(__name__)


@app.route('/submit', methods=['POST'])
def submit():
    form_data = dict(request.form)
    collection.insert_one(form_data)
    return "Data submitted successfully!"


# @app.route('/submit', methods=['POST'])
# def submit():

#     form_data = dict(request.form)

#     # SIMULATE ERROR
#     raise Exception("Testing error handling!")

#     collection.insert_one(form_data)

#     return "Data submitted successfully!", 200


@app.route('/data', methods=['GET'])
def get_data():

    data = list(collection.find({}, {'_id': 0}))
    return jsonify(data)


if __name__ == '__main__':
    app.run(debug=True, port=5001)