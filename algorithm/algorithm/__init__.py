from flask import Blueprint
algorithm_bp = Blueprint('algorithm', __name__)
from functools import wraps

def before(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        something = None

        return f(something, *args, **kwargs)
    return decorator


from algorithm.info import *
from algorithm.op import *