# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 12.6

# Usar la imagen oficial de TensorFlow con soporte para GPU
FROM tensorflow/tensorflow:2.16.1-gpu

# Configurar zona horaria
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Actualizar apt-get e instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git vim curl gfortran \
    libopenblas-dev liblapack-dev build-essential \
    python3-distutils python3-dev \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Actualizar pip y setuptools
RUN python3 -m pip install --upgrade pip setuptools wheel

# Instalar paquetes de análisis y visualización
RUN python3 -m pip install pandas matplotlib seaborn scikit-learn nltk spacy transformers wordcloud gensim regex tqdm tensorboard scikeras

# Instalar Jupyter Notebook (ya está incluido, pero aseguramos la versión)
RUN python3 -m pip install --upgrade jupyter

# Instalar NumPy (si es necesario)
RUN python3 -m pip install --upgrade numpy

# Descargar datos adicionales para NLTK y SpaCy
RUN python3 -m nltk.downloader punkt stopwords
RUN python3 -m spacy download en_core_web_sm
RUN python3 -m spacy download es_core_news_sm

# Configurar directorio de trabajo
WORKDIR /tf

# Exponer puertos para Jupyter y TensorBoard
EXPOSE 8888
EXPOSE 6006

# Comando para iniciar Jupyter y TensorBoard
CMD ["bash", "-c", "jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root & tensorboard --logdir=/tf/logs --host=0.0.0.0 --port=6006 & tail -f /dev/null"]
