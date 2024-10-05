# Imagen base de CUDA 12.6 con Ubuntu 24.04
FROM nvidia/cuda:12.6.1-base-ubuntu24.04

# Configurar zona horaria a UTC-5 (Guayaquil)
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Actualizar paquetes y añadir dependencias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    vim \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear un entorno virtual para evitar problemas con el entorno gestionado externamente
RUN python3 -m venv /opt/venv

# Activar el entorno virtual e instalar PyTorch con soporte para GPU y CUDA 11.8
RUN /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    && /opt/venv/bin/pip install nltk spacy transformers

# Descargar datos adicionales de NLTK y spaCy
RUN /opt/venv/bin/python -m nltk.downloader punkt stopwords
RUN /opt/venv/bin/python -m spacy download en_core_web_sm
RUN /opt/venv/bin/python -m spacy download es_core_news_sm

# Establecer el directorio de trabajo
WORKDIR /workspace

# Activar el entorno virtual automáticamente al iniciar el contenedor
ENV PATH="/opt/venv/bin:$PATH"

# Comando por defecto al iniciar el contenedor
CMD ["/bin/bash"]

