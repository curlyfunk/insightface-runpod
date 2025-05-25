FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Инсталиране на системни зависимости
RUN apt-get update && apt-get install -y \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Инсталиране на Python зависимости с фиксирани версии (бърз билд)
RUN pip install --no-cache-dir \
    opencv-python-headless==4.7.0.72 \
    scikit-image==0.21.0 \
    flask==2.3.3 \
    runpod==1.7.9 \
    onnxruntime-gpu==1.16.3 \
    insightface==0.7.3 \
    matplotlib==3.7.3 \
    scikit-learn==1.3.0 \
    tqdm==4.66.1 \
    easydict==1.10 \
    albumentations==1.3.1

# Изтегляне на InsightFace (без git)
RUN wget https://github.com/deepinsight/insightface/archive/refs/heads/master.zip -O /tmp/insightface.zip && \
    unzip /tmp/insightface.zip -d /app && \
    mv /app/insightface-master /app/insightface && \
    rm /tmp/insightface.zip

# Изтегляне на моделите
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# Копиране на handler
COPY handler.py /app/
WORKDIR /app

# Стартиране
CMD ["python", "-m", "runpod.serverless.start"]
