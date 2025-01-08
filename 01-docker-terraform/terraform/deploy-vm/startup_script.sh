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
wget https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip
unzip terraform_1.10.3_linux_amd64.zip
mv terraform /usr/local/bin/

# Clone Zoomcamp repo
git clone https://github.com/DataTalksClub/data-engineering-zoomcamp.git

# Clean up
rm ~/miniconda.sh terraform_1.10.3_linux_amd64.zip

echo "Startup script completed."
