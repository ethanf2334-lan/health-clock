from typing import Any


def success_response(data: Any = None, message: str = "ok"):
    return {"code": 0, "message": message, "data": data}


def error_response(code: int, message: str):
    return {"code": code, "message": message, "data": None}
