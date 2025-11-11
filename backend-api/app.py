from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/products')
def get_products():
    products = [
        {'id': 1, 'name': 'Product 1'},
        {'id': 2, 'name': 'Product 2'},
        {'id': 3, 'name': 'Product 3'}
    ]
    return jsonify(products)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
