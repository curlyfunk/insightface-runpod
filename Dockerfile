FROM runpod/python:3.10-ubuntu

# Системни зависимости
RUN apt-get update && apt-get install -y \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# pip инструменти
RUN pip install --upgrade pip setuptools wheel

# PyTorch и CUDA (леки и съвместими)
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Основни зависимости за InsightFace
RUN pip install --no-cache-dir \
    opencv-python-headless==4.7.0.72 \
    scikit-image \
    flask \
    runpod \
    onnxruntime-gpu==1.16.3 \
    insightface==0.7.3 \
    tqdm \
    easydict \
    albumentations

# Изтегляне на InsightFace
RUN git clone https://github.com/deepinsight/insightface.git /app/insightface

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
