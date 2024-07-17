from flask import current_app, request, jsonify, json
from algorithm import before, algorithm_bp

from utils._resp import resp, response_body
from utils._error import err_resp

import os
env = os.environ

@algorithm_bp.route('/test', methods=["GET", "POST"])
@before
def test(*args, **kwargs):
    if request.method == "POST":
        data = request.get_json()
        print(data)
        json_object = json.loads(data)
        response_data = json_object["data"]
        resp(response_body(200, "test", response_data))
    else:
        return "GET method not supported", 405


