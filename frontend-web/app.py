from flask import Flask, render_template
import requests

app = Flask(__name__)

@app.route('/')
def index():
    try:
        response = requests.get('http://backend-api-service:5000/api/products')
        response.raise_for_status()  # Raise an exception for bad status codes
        products = response.json()
    except requests.exceptions.RequestException as e:
        products = []
        print(f"Could not connect to backend API: {e}")

    return render_template('index.html', products=products)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
