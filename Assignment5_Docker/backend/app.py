from flask import Flask, request, jsonify

app = Flask(__name__)

# Temporary storage for submitted students
students = []

@app.route("/")
def root():
    return "Flask backend is running!"


@app.route("/submit", methods=["POST"])
def submit():

    name = request.form.get("name")
    age = request.form.get("age")
    city = request.form.get("city")

    # Validate input
    if not name or not age or not city:
        return "All fields are required", 400

    # Create student object
    student = {
        "name": name,
        "age": age,
        "city": city
    }

    # Store student
    students.append(student)

    # Return success response
    return f"""
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Success</title>

        <style>
            body {{
                font-family: Arial, sans-serif;
                background: #f4f7fb;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
            }}

            .container {{
                background: white;
                padding: 40px;
                border-radius: 16px;
                text-align: center;
                box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            }}

            h1 {{
                color: #16a34a;
            }}

            a {{
                display: inline-block;
                margin-top: 20px;
                color: #4f46e5;
                text-decoration: none;
            }}
        </style>
    </head>

    <body>

        <div class="container">

            <h1>Data Submitted Successfully!</h1>

            <p>Name: {name}</p>
            <p>Age: {age}</p>
            <p>City: {city}</p>

            <a href="http://localhost:5000/">
                ← Back to Form
            </a>

        </div>

    </body>

    </html>
    """


@app.route("/data", methods=["GET"])
def display_data():

    return jsonify(students)


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=False
    )

