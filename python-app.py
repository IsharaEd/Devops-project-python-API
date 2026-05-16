from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "ok"})

@app.route('/items')
def items():
    return jsonify({"items": ["item1", "item2", "item3"]})

@app.route('/users')
def users():
    return jsonify({"users": ["alice", "bob", "charlie"]})

@app.route('/version')
def version():
    return jsonify({"version": "1.0.0", "app": "devops-app"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)