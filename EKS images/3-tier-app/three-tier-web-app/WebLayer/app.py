import os
import logging
from flask import Flask, render_template, request, redirect, make_response
import json
import requests

logging.basicConfig(level=logging.ERROR)

app = Flask(__name__)
APP_URL = os.environ.get('APP_URL', 'http://app-service:4000')

@app.route('/')
def index():
    todos = {}
    try:
        response = requests.get(f"{APP_URL}/", timeout=60)
        todos = json.loads(response.content)
    except Exception as e:
        logging.error(f"Failed to fetch todos: {e}")
        pass

@app.route('/api/create', methods=['POST'])
def create():
    try:
        requests.post(f"{APP_URL}/create", data=request.form, timeout=60)
    except Exception as e:
        logging.error(f"Create failed: {e}")
        pass
def update():
    try:
        requests.post(f"{APP_URL}/update", data=request.form, timeout=60)
    except Exception as e:
        logging.error(f"Update failed: {e}")
        pass
def complete(task_id):
    try:
        requests.post(f"{APP_URL}/complete/{task_id}", timeout=60)
    except Exception as e:
        logging.error(f"Complete failed: {e}")
        pass

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
