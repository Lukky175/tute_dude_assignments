from flask import Flask, request, render_template, redirect
from datetime import datetime
import requests

app = Flask(__name__)

@app.route('/')
def root():
    day_of_week = datetime.today().strftime("%A")
    return render_template('index.html', day_of_week=day_of_week)


@app.route('/submit', methods=['POST'])
def submit():

    form_data = dict(request.form)
    try:
        response = requests.post(
            'http://127.0.0.1:5001/submit',
            data=form_data
        )

        if response.status_code == 200:
            return response.text

        else:
            return render_template(
                'index.html',
                day_of_week=datetime.today().strftime("%A"),
                error=response.text
            )

    except requests.exceptions.RequestException as e:
        return render_template(
            'index.html',
            day_of_week=datetime.today().strftime("%A"),
            error=str(e)
        )


@app.route('/data')
def display_data():
    response = requests.get('http://127.0.0.1:5001/data')
    data = response.json()
    return render_template( 'data.html', data=data)


if __name__ == '__main__':
    app.run(debug=True, port=5000)