#!/bin/bash
# Update and upgrade packages
apt-get update && apt-get upgrade -y

# Install prerequisites
apt-get install -y curl wget git build-essential

# Install Conda
curl -o ~/miniconda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ~/miniconda.sh -b -p /opt/miniconda
echo 'export PATH="/opt/miniconda/bin:$PATH"' >> /etc/profile.d/conda.sh
source /etc/profile.d/conda.sh

# Install Docker
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Install Terraform
# Download Terraform binary
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip -O /tmp/terraform.zip

# Unzip the binary
unzip /tmp/terraform.zip -d /tmp/

# Move the binary to /usr/local/bin
mv /tmp/terraform /usr/local/bin/

# Set proper permissions
chmod 755 /usr/local/bin/terraform

# Clone Zoomcamp repo
# git clone https://github.com/DataTalksClub/data-engineering-zoomcamp.git

# Clean up
rm ~/miniconda.sh /tmp/terraform.zip

echo "Startup script completed."
