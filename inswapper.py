import insightface
import numpy as np
import cv2
import base64
from io import BytesIO
from PIL import Image

# Зареждане на модела
model_path = "checkpoints/inswapper_128.onnx"
app = insightface.app.FaceAnalysis(name="buffalo_l", root="checkpoints/models")
app.prepare(ctx_id=0)
swapper = insightface.model_zoo.get_model(model_path, providers=['CUDAExecutionProvider'])

def b64_to_img(base64_string):
    img_data = base64.b64decode(base64_string)
    img = Image.open(BytesIO(img_data)).convert("RGB")
    return np.array(img)

def img_to_b64(img_array):
    pil_img = Image.fromarray(img_array)
    buffer = BytesIO()
    pil_img.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode("utf-8")

def swap_face(source_b64, target_b64):
    src_img = b64_to_img(source_b64)
    tgt_img = b64_to_img(target_b64)

    src_faces = app.get(src_img)
    tgt_faces = app.get(tgt_img)

    if len(src_faces) == 0 or len(tgt_faces) == 0:
        return "No face detected."

    swapped = swapper.get(tgt_img, tgt_faces[0], src_faces[0], paste_back=True)
    return img_to_b64(swapped)
