from flask import Blueprint
wxService_bp = Blueprint('wxService', __name__)
from functools import wraps

def get_access_token(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        access_token = None

        return f(access_token, *args, **kwargs)
    return decorator


from wxService.info import *
from wxService.op import *
