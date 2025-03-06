#!/bin/bash

# Log file
LOG_FILE="/var/log/startup_script.log"

# Update and upgrade packages
echo "Updating and upgrading packages..." | tee -a $LOG_FILE
apt-get update && apt-get upgrade -y | tee -a $LOG_FILE

# Install prerequisites
echo "Installing prerequisites..." | tee -a $LOG_FILE
apt-get install -y curl wget git build-essential openjdk-11-jdk bzip2 | tee -a $LOG_FILE

# Install Java
echo "Installing Java..." | tee -a $LOG_FILE
wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz | tee -a $LOG_FILE
tar xzfv openjdk-11.0.2_linux-x64_bin.tar.gz -C /opt/ | tee -a $LOG_FILE
ln -s /opt/jdk-11.0.2 /usr/lib/jvm/java-11-openjdk-amd64
rm openjdk-11.0.2_linux-x64_bin.tar.gz | tee -a $LOG_FILE

# Set JAVA_HOME and update PATH globally
echo "Setting JAVA_HOME and updating PATH..." | tee -a $LOG_FILE
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /etc/profile.d/java.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh

# Mount the additional disk
echo "Mounting additional disk..." | tee -a $LOG_FILE
sudo mkdir -p /mnt/disks/additional-disk
sudo mount -o discard,defaults /dev/disk/by-id/google-${var.machine_name}-disk /mnt/disks/additional-disk
sudo chmod a+w /mnt/disks/additional-disk

# Add the disk to /etc/fstab for automatic mounting on reboot
echo "Adding disk to /etc/fstab..." | tee -a $LOG_FILE
echo "/dev/disk/by-id/google-${var.machine_name}-disk /mnt/disks/additional-disk ext4 discard,defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Install Spark
echo "Installing Spark..." | tee -a $LOG_FILE
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz | tee -a $LOG_FILE
tar xzfv spark-3.3.2-bin-hadoop3.tgz -C /opt/ | tee -a $LOG_FILE
ln -s /opt/spark-3.3.2-bin-hadoop3 /opt/spark
rm spark-3.3.2-bin-hadoop3.tgz | tee -a $LOG_FILE

# Set SPARK_HOME and update PATH globally
echo "Setting SPARK_HOME and updating PATH..." | tee -a $LOG_FILE
echo "export SPARK_HOME=/opt/spark" >> /etc/profile.d/spark.sh
echo "export PATH=\$SPARK_HOME/bin:\$PATH" >> /etc/profile.d/spark.sh

# Install Miniconda
echo "Installing Miniconda..." | tee -a $LOG_FILE
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh | tee -a $LOG_FILE
bash miniconda.sh -b -p /opt/conda | tee -a $LOG_FILE
rm miniconda.sh | tee -a $LOG_FILE

# Set environment variables for Miniconda
echo "Setting environment variables for Miniconda..." | tee -a $LOG_FILE
echo "export PATH=/opt/conda/bin:\$PATH" >> /etc/profile.d/conda.sh

# Source the profile to update the current shell
source /etc/profile

# Install python packages using Conda
echo "Installing pandas and pyspark using Conda..." | tee -a $LOG_FILE
/opt/conda/bin/conda install -y pandas pyspark | tee -a $LOG_FILE

# Install Jupyter
echo "Installing Jupyter..." | tee -a $LOG_FILE
/opt/conda/bin/conda install -y jupyter | tee -a $LOG_FILE

# Test Spark
echo "Testing Spark..." | tee -a $LOG_FILE
/opt/spark/bin/spark-shell -e "val data = 1 to 10000; val distData = sc.parallelize(data); distData.filter(_ < 10).collect()" | tee -a $LOG_FILE

echo "Startup script completed." | tee -a $LOG_FILE