# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 11.8

# Imagen base con CUDA 11.8 y Ubuntu 22.04 (runtime)
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Configurar zona horaria
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependencias del sistema (sin nvidia-utils-530)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    vim \
    curl \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    build-essential \
    python3-distutils \
    python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar cuDNN 8
RUN apt-get update && apt-get install -y libcudnn8=8.9.1.* libcudnn8-dev=8.9.1.* \
    && apt-mark hold libcudnn8 libcudnn8-dev

# Crear y activar el entorno virtual
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Actualizar pip y setuptools
RUN pip install --upgrade pip setuptools wheel

# Instalar numpy, scipy y Cython
RUN pip install numpy scipy cython

# Instalar scikit-learn
RUN pip install scikit-learn

# Instalar PyTorch con CUDA 11.8 (aumentando el tiempo de espera y limpieza)
RUN pip install --no-cache-dir --progress-bar off --default-timeout=2000 \
    torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2+cu118 \
    --extra-index-url https://download.pytorch.org/whl/cu118

# Instalar TensorFlow compatible con CUDA 11.8
RUN pip install tensorflow==2.14.0

# Instalar otros paquetes necesarios
RUN pip install nltk spacy transformers jupyter pandas matplotlib seaborn \
    wordcloud gensim regex tqdm tensorboard

# Descargar datos adicionales para NLP
RUN python -m nltk.downloader punkt stopwords
RUN python -m spacy download en_core_web_sm
RUN python -m spacy download es_core_news_sm

# Configurar directorio de trabajo y PATH
WORKDIR /workspace

# Exponer puertos para Jupyter y TensorBoard
EXPOSE 8888
EXPOSE 6006

# CMD predeterminado para iniciar bash
CMD ["/bin/bash"]