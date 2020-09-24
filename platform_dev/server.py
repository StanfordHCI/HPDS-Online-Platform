from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import base64
import io
from PIL import Image, UnidentifiedImageError
import numpy as np
import datetime
from engineio.payload import Payload


app = Flask(__name__)
socketio = SocketIO(app)

# Avoid pesky "too many packets" error
Payload.max_decode_packets = 500

@app.route('/', methods=['POST', 'GET'])
def index():
    return render_template('index.html')

@socketio.on('image')
def image(data_image):

    # decode and convert into image
    headers, image = data_image.split(',', 1) 
    image = io.BytesIO(base64.b64decode(image))
    im = Image.open(image)
    try:
        im = im.convert('RGB')
        print(datetime.datetime.now())
    except UnidentifiedImageError:
        print("Error receiving")


    # Optionally emit a response back; here, we've just used the empty string
    emit('response_back', "")

if __name__ == '__main__':
    print("Starting Server")
    socketio.run(app)