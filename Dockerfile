# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB (164383872768 bytes)
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version: 12.7

# Imagen base con CUDA 11.8 y Ubuntu 22.04
FROM nvidia/cuda:11.8.0-base-ubuntu22.04

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear y activar el entorno virtual
RUN python3 -m venv /opt/venv

# Actualizar pip y setuptools
RUN /opt/venv/bin/pip install --upgrade pip setuptools

# Instalar numpy, scipy y Cython
RUN /opt/venv/bin/pip install numpy scipy cython

# Instalar la última versión de scikit-learn compatible
RUN /opt/venv/bin/pip install scikit-learn

# Instalar torch y otros paquetes (usando cu118 para CUDA 11.8)
RUN /opt/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Instalar otros paquetes necesarios
RUN /opt/venv/bin/pip install tensorflow nltk spacy transformers jupyter \
    pandas matplotlib seaborn wordcloud gensim regex tqdm

# Descargar datos adicionales para NLP
RUN /opt/venv/bin/python -m nltk.downloader punkt stopwords
RUN /opt/venv/bin/python -m spacy download en_core_web_sm
RUN /opt/venv/bin/python -m spacy download es_core_news_sm

# Configurar directorio de trabajo y PATH
WORKDIR /workspace
ENV PATH="/opt/venv/bin:$PATH"

CMD ["/bin/bash"]