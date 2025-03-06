

```shell
# Authenticate with GCP
gcloud auth configure-docker

# Build the Docker image
docker build -t gcr.io/$GCP_PROJECT_ID/spark-setup:latest -f $HOME/repos/data-eng-zoomcamp/05-batch/setup/Dockerfile .

# Push the Docker image to GCR
docker push gcr.io/$GCP_PROJECT_ID/spark-setup:latest
```


```bash
gcloud builds submit --tag gcr.io/$GCP_PROJECT_ID/spark-setup:latest
```