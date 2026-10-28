import uuid

from flask import Blueprint, jsonify, request

from app import storage
from app.auth import current_account

uploads = Blueprint("uploads", __name__)


@uploads.post("/api/files")
def upload_file():
    file = request.files["file"]
    key = f"{current_account().id}/{uuid.uuid4()}/{file.filename}"
    storage.put(key, file.stream, content_type=file.mimetype)
    return jsonify({"key": key}), 201
