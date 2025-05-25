FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Системни зависимости
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ffmpeg \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# pip инструменти – задължително за билда
RUN pip install --upgrade pip setuptools wheel

# Минимален и стабилен set от зависимости
RUN pip install --no-cache-dir \
    runpod \
    insightface==0.7.3 \
    onnxruntime-gpu==1.16.3 \
    opencv-python-headless==4.7.0.72 \
    flask \
    tqdm

# Изтегляне на модела
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# Копиране на handler
COPY handler.py /app/
WORKDIR /app

# Старт
CMD ["python", "-m", "runpod.serverless.start"]
