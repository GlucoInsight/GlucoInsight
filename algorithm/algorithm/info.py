from datetime import datetime

import pandas as pd
from flask import current_app, request, jsonify, json
from algorithm import before, algorithm_bp

from utils._resp import resp, response_body
from utils._error import err_resp

from infer.glucotype import glucotype_predict
from infer.cal_neutri import nutrients_predict
from infer.identify_meal import meal_pattern_multiple_identify
from gpt_call import gpt_call

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


@algorithm_bp.route('/predict_nutrients', methods=["POST"])
@before
def predict_nutrients(*args, **kwargs):
    data_list = request.get_json()
    print(data_list)
    # preprocess
    timestamps = [data["timestamp"] for data in data_list]
    cgm_time_series = [data["glucoValue"] for data in data_list]

    # timestamps转换为'2024-07-16 08:00:00'的format
    # 将时间戳转换为指定格式
    formatted_timestamps = []
    for timestamp in timestamps:
        # 将列表转换为字符串
        timestamp_str = f"{timestamp[0]}-{timestamp[1]:02d}-{timestamp[2]:02d} {timestamp[3]:02d}:{timestamp[4]:02d}:00"
        dt = pd.to_datetime(timestamp_str, format='%Y-%m-%d %H:%M:%S')  # 将字符串转换为Timestamp对象
        formatted_timestamps.append(dt)

    print(formatted_timestamps[0])
    print(type(formatted_timestamps[0]))

    identified_meal_timestamps_range = meal_pattern_multiple_identify(cgm_time_series, formatted_timestamps)

    result_body = []
    for (timestamp_start, timestamp_end) in identified_meal_timestamps_range:
        # 获取对应timestamp的index
        timestamp_start_idx = formatted_timestamps.index(timestamp_start)
        timestamp_end_idx = formatted_timestamps.index(timestamp_end)
        nutrients_predict_result = nutrients_predict(cgm_time_series[timestamp_start_idx:timestamp_end_idx])
        result_body.append({
            "timestamp_start": timestamp_start.isoformat(),
            "timestamp_end": timestamp_end.isoformat(),
            "protein": float(nutrients_predict_result[2][0][0]),
            "fat": float(nutrients_predict_result[0][0][0]),
            "carbohydrate": float(nutrients_predict_result[1][0][0])
        })


    resp(response_body(200, "predict_nutrients", result_body))

@algorithm_bp.route('/chatgpt', methods=["POST"])
@before
def chatgpt(*args, **kwargs):
  data = request.get_json()
  json_object = json.loads(data)

  prompt = json_object["prompt"]
  response_data = gpt_call(prompt)
  resp(response_body(200, "chatgpt", response_data))

