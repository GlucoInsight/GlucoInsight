from flask import current_app, request, jsonify, json
from algorithm import before, algorithm_bp

from utils._resp import resp, response_body
from utils._error import err_resp

from infer.glucotype import glucotype_predict

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


@algorithm_bp.route('/predict_gluco', methods=["POST"])
@before
def predict_gluco(*args, **kwargs):
    data = request.get_json()
    print(data)
    json_object = json.loads(data)
    response_data = json_object
    resp(response_body(200, "predict_gluco", response_data))

@algorithm_bp.route('/predict_gluco_type', methods=["POST"])
@before
def predict_gluco_type(*args, **kwargs):
    data = request.get_json()
    print(data)
    # json_object = json.loads(data)

    # preprocess
    age = data["age"]
    bmi = data["bmi"]
    glucoList = data["glucoList"]
    # 只取glucoList中的predictGluco为一个新的list，glucoList结构为[{'timestamp': [2024, 7, 17, 9, 12, 52], 'predictGluco': 90.0}, {'timestamp': [2024, 7, 17, 9, 12, 33], 'predictGluco': 85.0}]
    cgm_time_series = [gluco["predictGluco"] for gluco in glucoList]

    # print(f'age: {age}, bmi: {bmi}, cgm_time_series: {cgm_time_series}')
    result = glucotype_predict(age, bmi, cgm_time_series)
    # print(f"result: {result}")

    resp(response_body(200, "predict_gluco", result))