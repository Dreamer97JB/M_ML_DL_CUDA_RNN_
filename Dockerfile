# Equipo utilizado para construir esta imagen de Docker:
# CPU: AMD Ryzen 7 5800H with Radeon Graphics, 8 núcleos, 16 hilos
# RAM: 16 GB
# GPU: NVIDIA GeForce RTX 3050 Ti, Driver Version: 566.03, CUDA Version 12.6

# Use the official TensorFlow image with Python 3.11 and GPU support
FROM tensorflow/tensorflow:2.15.0-gpu-jupyter

# Set timezone
ENV TZ="America/Guayaquil"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Upgrade pip to ensure compatibility with new packages
RUN pip install --upgrade pip

# Install essential Python libraries for data science and machine learning
# Removed tensorflow.keras as it is part of TensorFlow
RUN pip install numpy pandas matplotlib seaborn scikit-learn regex nltk scikeras

# Download additional data for NLTK
RUN python -c "import nltk; nltk.download('punkt'); nltk.download('stopwords'); nltk.download('wordnet')"

# Set working directory
WORKDIR /tf

# Expose ports for Jupyter Notebook and TensorBoard
EXPOSE 8888
EXPOSE 6006

# Command to start Jupyter Notebook and TensorBoard
CMD ["bash", "-c", "jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root & tensorboard --logdir=/tf/logs --host=0.0.0.0 --port=6006 & tail -f /dev/null"]