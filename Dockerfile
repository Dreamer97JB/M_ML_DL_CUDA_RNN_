# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 11.8

# Imagen base con CUDA 12.6 y Ubuntu 22.04
FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

# Configurar zona horaria
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependencias del sistema y herramientas NVIDIA
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git vim curl gfortran \
    libopenblas-dev liblapack-dev build-essential \
    python3-distutils python3-dev \
    nvidia-utils-530 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar cuDNN (compatible con CUDA 12.6)
RUN apt-get update && apt-get install -y libcudnn8=8.9.1.* libcudnn8-dev=8.9.1.* \
    && apt-mark hold libcudnn8 libcudnn8-dev

# Variables de entorno para CUDA y cuDNN
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV PATH /usr/local/cuda/bin:$PATH

# Crear y activar el entorno virtual
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Actualizar pip y setuptools
RUN pip install --upgrade pip setuptools wheel

# Instalar TensorFlow compatible con CUDA 12.6 y NumPy compatible
RUN pip install "tensorflow==2.14.0" "numpy<2"

# Instalar paquetes de análisis y visualización
RUN pip install pandas matplotlib seaborn scikit-learn

# Instalar NLTK, SpaCy y otros paquetes NLP
RUN pip install nltk spacy transformers wordcloud gensim regex tqdm

# Descargar datos adicionales para NLTK y SpaCy
RUN python -m nltk.downloader punkt stopwords
RUN python -m spacy download en_core_web_sm
RUN python -m spacy download es_core_news_sm

# Configurar directorio de trabajo
WORKDIR /workspace

# Exponer puertos para Jupyter y TensorBoard
EXPOSE 8888
EXPOSE 6006

# CMD predeterminado para iniciar bash
CMD ["/bin/bash"]