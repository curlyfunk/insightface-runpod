FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Инсталиране на зависимости
RUN apt-get update && apt-get install -y \
    git \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Инсталиране на Python пакети поотделно, за да избегнем конфликти
RUN pip install --no-cache-dir opencv-python-headless
RUN pip install --no-cache-dir scikit-image
RUN pip install --no-cache-dir flask
RUN pip install --no-cache-dir runpod
RUN pip install --no-cache-dir onnxruntime-gpu
RUN pip install --no-cache-dir insightface

# Клониране на InsightFace хранилището
RUN git clone https://github.com/deepinsight/insightface.git /app/insightface

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
