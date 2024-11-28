# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 11.8

# Imagen base con CUDA 12.5 y Ubuntu 22.04
FROM nvidia/cuda:12.5.0-runtime-ubuntu22.04

# Configurar zona horaria
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar dependencias del sistema y herramientas necesarias
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git vim curl gfortran \
    libopenblas-dev liblapack-dev build-essential \
    python3-distutils python3-dev \
    nvidia-utils-530 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*



# Instalar cuDNN compatible con CUDA 12.5
RUN apt-get update && apt-get install -y libcudnn8=8.9.5.* libcudnn8-dev=8.9.5.* \
    && apt-mark hold libcudnn8 libcudnn8-dev

# Variables de entorno para cuDNN y CUDA
ENV CUDA_HOME=/usr/local/cuda
ENV CUDA_PATH=/usr/local/cuda
ENV LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/lib/x86_64-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda/bin:$PATH

# Crear y activar el entorno virtual
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Actualizar pip y setuptools
RUN pip install --upgrade pip setuptools wheel

# Instalar TensorFlow 2.16.1 compatible con CUDA 12.5 y cuDNN 8.9
RUN pip install --force-reinstall "tensorflow==2.16.1" 

# Instalar paquetes de análisis y visualización
RUN pip install pandas matplotlib seaborn scikit-learn nltk spacy transformers wordcloud gensim regex tqdm tensorboard

# Remove the duplicate NumPy installation and use a single, explicit install
RUN pip install "numpy==1.26.4" --force-reinstall

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