### Lots of IAM project/role adding
```bash
# Allow pulling images from Artifact Registry (or Container Registry)
gcloud projects add-iam-policy-binding data-eng-446809 \
  --member="serviceAccount:my-vm-sa@data-eng-446809.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"

# Allow managing VM instances (if needed)
gcloud projects add-iam-policy-binding data-eng-446809 \
  --member="serviceAccount:my-vm-sa@data-eng-446809.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin.v1"

# Allow logging (recommended for troubleshooting)
gcloud projects add-iam-policy-binding data-eng-446809 \
  --member="serviceAccount:my-vm-sa@data-eng-446809.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding data-eng-446809 \
  --member="serviceAccount:terraform-runner@data-eng-446809.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud iam service-accounts add-iam-policy-binding my-vm-sa@data-eng-446809.iam.gserviceaccount.com \
  --member="serviceAccount:terraform-runner@data-eng-446809.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountTokenCreator"

gcloud iam service-accounts keys delete
```

### Launch a notebook
```bash
jupyter-notebook --no-browser --port=8888
```

### ssh to VM
```bash
gcloud compute ssh my-vm --zone='australia-southeast1-b'
```

### Port forwarding
```bash
gcloud compute ssh my-vm --zone='australia-southeast1-b' -- -L 4040:localhost:4040
gcloud compute ssh my-vm --zone='australia-southeast1-b' -- -L 8080:localhost:8080
```
