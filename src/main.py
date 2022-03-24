import hashlib
import os
from io import BytesIO

import qrcode
from flask import jsonify
from google.cloud import storage


def make_qrcode(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    request_json = request.get_json()

    qrtext = ""

    if request.args and 'qrtext' in request.args:
        qrtext = request.args.get('qrtext')
    elif request_json and 'qrtext' in request_json:
        qrtext = request_json['qrtext']
    
    if not qrtext:
        return "No text provided. (Usage: ?qrtext=your+text+here)"
    
    img = qrcode.make(qrtext)
    buffered = BytesIO()
    img.save(buffered, format="PNG")
    file_string = buffered.getvalue()

    filename = f'{hashlib.sha256(file_string).hexdigest()}.png'
    bucketname = os.environ.get('BUCKET_NAME', 'Error; cannot determine GCS bucket')

    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucketname)
    file_url = f'https://storage.googleapis.com/{bucketname}/{filename}'
    blob = bucket.blob(filename)

    blob.upload_from_string(file_string)

    return_data = {
        'qrcode_url' : file_url
    }

    return jsonify(return_data)
