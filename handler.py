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
        try:
            img_data = base64.b64decode(b64)
            nparr = np.frombuffer(img_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            return img
        except Exception:
            return None

    source_img = b64_to_img(source_b64)
    target_img = b64_to_img(target_b64)

    if source_img is None or target_img is None:
        return {"status": "error", "message": "Invalid base64 input."}

    # Детекция на лица
    source_faces = app.get(source_img)
    target_faces = app.get(target_img)

    if not source_faces or not target_faces:
        return {"status": "error", "message": "No faces detected."}

    # Изпълняваме face swap само с първите лица
    result_img = swapper.get(target_img, target_faces[0], source_faces[0])

    # Кодиране обратно към base64
    _, buffer = cv2.imencode('.png', result_img)
    result_b64 = base64.b64encode(buffer).decode("utf-8")
    return {"status": "success", "result_image": result_b64}

# RunPod handler
def handler(event):
    input_data = event["input"]
    source_image = input_data.get("source_image")
    target_image = input_data.get("target_image")

    if not source_image or not target_image:
        return {"status": "error", "message": "Missing input images."}

    result = swap_face(source_image, target_image)
    return result

runpod.serverless.start({"handler": handler})
