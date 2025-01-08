# Setting up VM on GCP

## Table of Contents
1. []()


## Steps to setting Up a VM through console
Following steps from Data Engineering course [here](https://www.youtube.com/watch?v=ae-CV2KfoN0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=14&ab_channel=DataTalksClub%E2%AC%9B)

1. Select relevant project
2. Compute Engine &rarr; VM Instances
3. Generate ssh key `ssh-keygen -t rsa -f ~/.ssh/gcp -C plynch`
4. Navigate to Metadata and upload public ssh key *gcp.pub*
5. Back to VM Instances, create Instance. Enter name and region.
6. Choose a low cost setup eg E2
7. Change operating system to Ubuntu in OS and Storage
8. Create instance

### SSH to VM
```shell
ssh -i ~/.ssh/gcp plynch@<External IP>
```

### Data Engineering setup specific
1. SSH to VM
2. Install Ananconda
```shell
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
```
3. Run installation `bash Anaconda....`
4. Install Docker
```shell
sudo apt-get update
sudo apt-get install docker.io
```
5. Run docker without sudo, steps [here](https://github.com/sindresorhus/guides/blob/main/docker-without-sudo.md)
6. Install docker compose
```shell
mkdir bin
cd bin
wget  - O docker-compose https://github.com/docker/compose/releases/download/v2.32.1/docker-compose-linux-x86_64
chmod +x docker-compose
```
7. Add PATH to bin to .bashrc `nano ~/.bashrc`
```shell
export PATH="${HOME}/bin:${PATH}"
```
8. Clone repo
```shell
git clone https://github.com/DataTalksClub/data-engineering-zoomcamp.git
```
9. Test docker-compose
```shell
cd ~/data-engineering-zoomcamp/01-docker-terraform/2_docker_sql
docker-compose up -d
```
10. Install postgres command line tool
```shell
pip install pgcli
```
11. Connect to database
```shell
pgcli -h localhost -U root -d ny_taxi
```
12. If any issues then reinstall pgcli with conda
```shell
pip uninstall pgcli
conda install -c conda-forge pgcli
```
13. Run `docker ps` to see which port docker is running on. Using *ports* in VS code, forward the postgres port.
14. Move to `data-engineering-zoomcamp/01-docker-terraform/2_docker_sql` and run:
```shell
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
gzip -d yellow_tripdata_2021-01.csv.gz
```
15. Launch jupyter `jupyter notebook`
16. Install terraform
```shell
cd ~/bin/
wget https://releases.hashicorp.com/terraform/1.10.3/terraform_1.10.3_linux_amd64.zip
unzip terraform..
```
17. Copy service account key
```shell
sftp de-zoomcamp
mkdir .gc
cd .gc
put ny-taxi....json
```
18. Setup gcloud authentication
```bash
export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/ny-taxi...json
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```
19. terraform
```shell
cd data-engineering-zoomcamp/01-docker-terraform/1_terraform_gcp/terraform/terraform_
terraform init
terraform plan
terraform apply
```