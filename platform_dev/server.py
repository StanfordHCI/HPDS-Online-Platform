from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import base64
import io
from PIL import Image
import numpy as np

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/', methods=['POST', 'GET'])
def index():
    return render_template('index.html')

@socketio.on('image')
def image(data_image):

    # decode and convert into image
    headers, image = data_image.split(',', 1) 
    image = io.BytesIO(base64.b64decode(image))
    im = Image.open(image)
    im = im.convert('RGB')
    print(np.linalg.norm(np.asarray(im)))


    # Optionally emit a response back; here, we've just used the empty string
    emit('response_back', "")

if __name__ == '__main__':
    print("Starting Server")
    socketio.run(app)