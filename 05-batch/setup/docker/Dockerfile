FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV SPARK_HOME=/opt/spark
ENV PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH

# Install prerequisites
RUN apt-get update && apt-get install -y curl wget git build-essential openjdk-11-jdk bzip2 && \
    rm -rf /var/lib/apt/lists/*
    
# Install Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz && \
    tar xzfv spark-3.3.2-bin-hadoop3.tgz -C /opt/ && \
    ln -s /opt/spark-3.3.2-bin-hadoop3 /opt/spark && \
    rm spark-3.3.2-bin-hadoop3.tgz

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Set environment variables for Miniconda
ENV PATH=/opt/conda/bin:$PATH

# Set the working directory
WORKDIR /workspace

# Default command
CMD ["bash"]