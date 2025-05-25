FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Инсталиране на системни зависимости + build инструменти
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ffmpeg \
    libsm6 \
    libxext6 \
    build-essential \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# pip инструменти
RUN pip install --upgrade pip setuptools wheel

# Python зависимости (фиксирани версии)
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

# Изтегляне на моделите
RUN mkdir -p /app/models && \
    wget -O /app/models/buffalo_l.zip https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    unzip /app/models/buffalo_l.zip -d /app/models/ && \
    rm /app/models/buffalo_l.zip

# Копиране на handler.py
