FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Инсталиране на системни зависимости
RUN apt-get update && apt-get install -y \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Инсталиране на Python зависимости
RUN pip install --no-cache-dir \
    opencv-python-headless \
    scikit-image \
    flask \
    runpod \
    onnxruntime-gpu \
    insightface

# Изтегляне на InsightFace repo без git
RUN wget https://github.com/deepinsight/insightface/archive/refs/heads/master.zip -O /tmp/insightface.zip && \
    unzip /tmp/insightface.zip -d /app && \
    mv /app/insightface-master /app/insightface && \
    rm /tmp/insightface.zip

# Изтегляне на предварително обучени модели
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# Копиране на handler файла
COPY handler.py /app/
WORKDIR /app

# Стартиране на RunPod handler
CMD ["python", "-m", "runpod.serverless.start"]
