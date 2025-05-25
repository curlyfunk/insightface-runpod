import runpod
import base64
import cv2
import numpy as np
import insightface
from insightface.app import FaceAnalysis
from insightface.app import FaceSwap
from io import BytesIO
from PIL import Image

# Инициализиране на модела
face_analyzer = FaceAnalysis(name="buffalo_l", root="/app/models")
face_analyzer.prepare(ctx_id=0, det_size=(640, 640))
face_swapper = FaceSwap()

def decode_image(base64_string):
    """Декодиране на base64 изображение"""
    img_data = base64.b64decode(base64_string)
    img = Image.open(BytesIO(img_data))
    return cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

def encode_image(img, format='jpg'):
    """Кодиране на изображение в base64"""
    is_success, buffer = cv2.imencode(f'.{format}', img)
    return base64.b64encode(buffer).decode('utf-8')

def handler(event):
    """RunPod handler функция"""
    try:
        # Извличане на входните данни
        input_data = event["input"]
        source_image = decode_image(input_data["source_image"])
        target_image = decode_image(input_data["target_image"])
        params = input_data.get("params", {})
        
        # Извличане на параметри
        face_index = params.get("face_index", 0)
        target_face_index = params.get("target_face_index", 0)
        enhance_face = params.get("enhance_face", False)
        
        # Анализ на лицата
        source_faces = face_analyzer.get(source_image)
        target_faces = face_analyzer.get(target_image)
        
        if len(source_faces) <= face_index or len(target_faces) <= target_face_index:
            return {
                "error": "Face index out of range"
            }
        
        # Изпълнение на подмяна на лице
        result_img = face_swapper.get(target_image, target_faces[target_face_index], 
                                     source_faces[face_index], paste_back=True)
        
        # Кодиране на резултата
        result_encoded = encode_image(result_img, 'jpg')
        
        return {
            "output": {
                "image": result_encoded,
                "success": True
            }
        }
    except Exception as e:
        return {
            "error": str(e)
        }

# Стартиране на RunPod serverless
runpod.serverless.start({"handler": handler})
