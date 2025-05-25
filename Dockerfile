FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Инсталиране на зависимости
RUN apt-get update && apt-get install -y \
    git \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Инсталиране на Python пакети
RUN pip install --no-cache-dir \
    insightface \
    onnxruntime-gpu \
    opencv-python \
    scikit-image \
    flask \
    runpod

# Клониране на InsightFace хранилището
RUN git clone https://github.com/deepinsight/insightface.git /app/insightface

# Инсталиране на InsightFace
RUN pip install -e /app/insightface/python-package

# Изтегляне на предварително обучени модели
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# Копиране на кода на ендпойнта
COPY handler.py /app/
WORKDIR /app

# Стартиране на RunPod handler
CMD ["python", "-m", "runpod.serverless.start"]
