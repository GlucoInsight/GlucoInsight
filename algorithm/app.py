from flask import Flask, make_response
from flask_cors import *

import logging

from dotenv import load_dotenv

load_dotenv('./.env')

app = Flask(__name__)
app.config.from_pyfile('config.py')

from algorithm import algorithm_bp

app.register_blueprint(algorithm_bp, url_prefix='/api')

CORS(app, support_credentials=True)


@app.after_request
def after_request(resp):
	resp = make_response(resp)
	resp.headers['Access-Control-Allow-Origin'] = '*'
	resp.headers['Access-Control-Allow-Methods'] = 'GET,POST'
	resp.headers['Access-Control-Allow-Headers'] = 'content-type,token,Authorization'
	return resp

# app.after_request(after_request)

@app.route('/')
def home():
    # error(LOGIN_FAILED)
	return 'Hello Flask With Blueprint'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)