# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB (164383872768 bytes)
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 11.8

# Imagen base con CUDA 11.2.2 y Ubuntu 20.04
FROM nvidia/cuda:11.2.2-base-ubuntu20.04

# Configurar zona horaria
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nvidia-utils-530 \
    git \
    vim \
    curl \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    build-essential \
    libcudnn8=8.1.* libcudnn8-dev=8.1.* \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear y activar el entorno virtual
RUN python3 -m venv /opt/venv

# Actualizar pip y setuptools
RUN /opt/venv/bin/pip install --upgrade pip setuptools

# Instalar numpy, scipy y Cython
RUN /opt/venv/bin/pip install numpy==1.21.6 scipy==1.7.3 cython==0.29.32

# Instalar scikit-learn
RUN /opt/venv/bin/pip install scikit-learn==1.0.2

# Instalar TensorFlow y Torch
RUN /opt/venv/bin/pip install tensorflow==2.6.0 \
    torch==1.10.0 torchvision==0.11.0 torchaudio==0.10.0 --index-url https://download.pytorch.org/whl/cu112

# Instalar otros paquetes necesarios
RUN /opt/venv/bin/pip install nltk==3.6.7 spacy==3.2.4 transformers==4.18.0 \
    jupyter==1.0.0 pandas==1.3.5 matplotlib==3.5.1 seaborn==0.11.2 \
    wordcloud==1.8.1 gensim==4.1.2 regex==2022.3.15 tqdm==4.62.3 tensorboard==2.6.0

# Descargar datos adicionales para NLP
RUN /opt/venv/bin/python -m nltk.downloader punkt stopwords
RUN /opt/venv/bin/python -m spacy download en_core_web_sm
RUN /opt/venv/bin/python -m spacy download es_core_news_sm

# Configurar variables de entorno necesarias para CUDA
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
ENV CUDA_HOME=/usr/local/cuda

# Configurar directorio de trabajo y PATH
WORKDIR /workspace
ENV PATH="/opt/venv/bin:$PATH"

# CMD predeterminado para iniciar bash
CMD ["/bin/bash"]