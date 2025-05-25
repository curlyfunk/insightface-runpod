# Базов CUDA образ от RunPod с PyTorch 2.0.1 и Python 3.10
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# 1. Инсталиране на системни зависимости и инструменти за компилация
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ffmpeg \
    libsm6 \
    libxext6 \
    build-essential \
    cmake \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

# 2. Ъпдейт на pip и build-инструменти
RUN pip install --upgrade pip setuptools wheel

# 3. Инсталиране на всички нужни Python библиотеки с фиксирани версии
RUN pip install --no-cache-dir \
    runpod==1.7.9 \
    insightface==0.7.3 \
    onnxruntime-gpu==1.16.3 \
    opencv-python-headless==4.7.0.72 \
    flask==2.3.3 \
    tqdm==4.66.1 \
    easydict==1.10 \
    scikit-image==0.21.0 \
    albumentations==1.3.1

# 4. Изтегляне на InsightFace моделите (без git clone)
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# 5. Копиране на handler файла
COPY handler.py /app/
WORKDIR /app

# 6. Стартиране на RunPod Serverless
CMD ["python", "-m", "runpod.serverless.start"]
