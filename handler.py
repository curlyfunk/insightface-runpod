import runpod
import cv2
import numpy as np
import base64
from insightface.app import FaceAnalysis
from insightface.model_zoo.inswapper import INSwapper

# Инициализация на моделите
app = FaceAnalysis(name='buffalo_l', providers=['CUDAExecutionProvider'])
app.prepare(ctx_id=0)

swapper = INSwapper(
    model_file="/workspace/runpod-worker-inswapper/checkpoints/inswapper_128.onnx",
    providers=['CUDAExecutionProvider']
)

def swap_face(source_b64, target_b64):
    # Декодиране на изображенията
    def b64_to_img(b64):
        img_data = base64.b64decode(b64)
        nparr = np.frombuffer(img_data, np.uint8)
        return cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    source