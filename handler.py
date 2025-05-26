import runpod
from inswapper import swap_face

def handler(event):
    input_data = event["input"]
    source_image = input_data.get("source_image")  # лице за слагане
    target_image = input_data.get("target_image")  # целево изображение

    result = swap_face(source_image, target_image)

    return {
        "status": "success",
        "result_image": result  # base64 изображение
    }

runpod.serverless.start({"handler": handler})
