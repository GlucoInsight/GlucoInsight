from flask import current_app, request
from wxService import get_access_token, wxService_bp

from utils._resp import resp, response_body
from utils._error import err_resp

import requests

import datetime

import os
env = os.environ


@wxService_bp.route('/Login', methods=["GET", "POST"])
@get_access_token
def login(*args, **kwargs):
    print(*args)
    reqArgs = request.args
    # reqJson = request.get_json(silent=False)
    # print(request.path, request.full_path, env.get('APPID'), env.get('APPSECRET'), request.args)
    res = requests.get(
        url='https://api.weixin.qq.com/sns/jscode2session',
        params={
            'appid': env.get('APPID'),
            'secret': env.get('APPSECRET'),
            'js_code': reqArgs.get('js_code'),
            'grant_type': 'authorization_code',
        }
    )
    # print(res.json())
    # return {'openid': res.json().get('openid')}
    resp(response_body(200, "Login", {'openid': res.json().get('openid'), 'current_timestamp': datetime.datetime.now().timestamp()}))
