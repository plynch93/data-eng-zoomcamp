This file contains the workings and answers for `Module 1 - Docker, SQL and Terraform`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/01-docker-terraform/homework.md).

## Docker and SQL

### Question 1. Knowing docker tags
First run the full help command for information on Docker.
```docker --help```
Then run through the ```--help``` outputs for each of:
 - `docker build`
 - `docker run`

<details>
    <summary>Snippet of docker run --help output</summary>

```shell
    Usage:  docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

    Create and run a new container from an image

    Aliases:
    docker container run, docker run

    Options:
        --add-host list                    Add a custom host-to-IP mapping (host:ip)
        ...
        --entrypoint string                Overwrite the default ENTRYPOINT of the image
        ...
    -i, --interactive                      Keep STDIN open even if not attached
        ...
        --rm                               Automatically remove the container when it exits
        ...
    -t, --tty                              Allocate a pseudo-TTY
        ...
    -w, --workdir string                   Working directory inside the container
```
</details>

**Question:**
Which tag has the following text? - *Automatically remove the container when it exits*

**Answer:**
`--rm`

### Question 2. Understanding docker first run
Use docker to run an image of python 3.9 in interactive mode with the entrypoint of bash.
Command ran:
```shell
docker run -it --entrypoint bash python:3.9
```
 - `-i` - interactive mode
 - `-t` - creates a terminal interface allowing interaction (like a shell prompt)
 - `--entrypoint bash` - Overwrites the dafault entrypoint (python) with bash

Using `pip list` get version of installed python packages.
```
Package    Version
---------- -------
pip        23.0.1
setuptools 58.1.0
wheel      0.45.1
```

**Question:**
What is version of the package *wheel* ?

**Answer:**
0.45.1

## Postgres setup
1. Use docker compose to start postgres and pgadmin:
```shell
docker-compose up
```
The existing yellow_taxi_trips should still be populated as reusing mount
2. Use jupyter notebook to inspect `green_tripdata`. Made changes to `ingest_data.py` script to make it more generic and move specfic mapping rules to additional functions.
3. Ingest `green_taxi_trips` with the python ingest script, ingest_data.py.
```shell
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"

python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=ny_taxi \
  --table_name=green_taxi_trips \
  --url=${URL}
```
4. Ingest `zones` with the python ingest script, ingest_data.py.
```shell
URL="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"

URL="https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"

python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=ny_taxi \
  --table_name=zones \
  --url=${URL}
```

### Question 3. Count records 

**Question:**
How many taxi trips were totally made on September 18th 2019?

Query used for answer:
```sql
SELECT 
    COUNT(1) 
FROM 
    green_taxi_trips 
WHERE 
	lpep_pickup_datetime >= '2019-09-18 00:00:00' AND 
	lpep_dropoff_datetime< '2019-09-19 00:00:00'
```

**Answer:**
15,612

### Question 4. Longest trip for each day

**Question:**
Which was the pick up day with the longest trip distance?

Query used for answer:
```sql
SELECT 
	MAX(trip_distance) AS max_distance,
	CAST(lpep_pickup_datetime AS DATE) as date
FROM 
    green_taxi_trips
GROUP BY 
    date
ORDER BY 
    max_distance DESC
LIMIT 5;
```

**Answer:**
2019-09-26

### Question 5. Three biggest pick up Boroughs

**Question:**
Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

Query used for answer:
```sql
WITH agg_results AS (
	SELECT 
		SUM(trips.total_amount) AS sum_amount,
		zones.borough AS borough
	FROM 
		green_taxi_trips trips
	INNER JOIN 
		zones ON trips.pulocationid=zones.locationid
	WHERE 
		CAST(trips.lpep_pickup_datetime AS DATE) = '2019-09-18'
	GROUP BY 
		borough
)
SELECT
	sum_amount,
	borough
FROM
	agg_results
WHERE 
	sum_amount > 50000
ORDER BY
	sum_amount DESC;
```

**ANSWER:**
"Brooklyn" "Manhattan" "Queens"

### Question 6. Largest tip

**Question:**
For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Query used for answer:
Needed two joins, to get pickup and dropoff locations
```sql
SELECT 
	MAX(tip_amount) AS max_tip,
	dropoff_zones.zone
FROM
	green_taxi_trips trips
INNER JOIN
	zones pickup_zones ON trips.pulocationid=pickup_zones.locationid
INNER JOIN
	zones dropoff_zones ON trips.dolocationid=dropoff_zones.locationid
WHERE
	trips.lpep_pickup_datetime >= '2019-09-01 00:00:00' AND 
	trips.lpep_dropoff_datetime < '2019-10-01 00:00:00' AND
	pickup_zones.zone = 'Astoria'
GROUP BY
	dropoff_zones.zone
ORDER BY
	max_tip DESC
LIMIT 5
```

## Terraform

For this going to use a GCP virtual machine. Have launched the VM using terraform files (here)[terraform/deploy-vm].
```bash
terraform init
terraform plan
terraform apply
```
Once VM is running then get external IP with:
`gcloud compute instances list`
Connect with:
```bash
ssh -i ~/.ssh/<key name> <user>@<External IP>
```
If service account keys are needed then use sftp (in a new terminal) with the same command as above, replacing ssh with sftp.
```bash
sftp -i ~/.ssh/<key name> <user>@<External IP>
```
Update values in `variables.tf`

Run `terraform apply`

Output:
```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.demo_dataset will be created
  + resource "google_bigquery_dataset" "demo_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "demo_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = {
          + "goog-terraform-provisioned" = "true"
        }
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "australia-southeast1"
      + max_time_travel_hours      = (known after apply)
      + project                    = "data-eng-446809"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = {
          + "goog-terraform-provisioned" = "true"
        }

      + access (known after apply)
    }

  # google_storage_bucket.demo-bucket will be created
  + resource "google_storage_bucket" "demo-bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "AUSTRALIA-SOUTHEAST1"
      + name                        = "data-eng-446809-terra-bucket"
      + project                     = (known after apply)
      + project_number              = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
        }
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type          = "AbortIncompleteMultipartUpload"
                # (1 unchanged attribute hidden)
            }
          + condition {
              + age                    = 1
              + matches_prefix         = []
              + matches_storage_class  = []
              + matches_suffix         = []
              + with_state             = (known after apply)
                # (3 unchanged attributes hidden)
            }
        }

      + soft_delete_policy (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.demo_dataset: Creating...
google_storage_bucket.demo-bucket: Creating...
google_storage_bucket.demo-bucket: Creation complete after 2s [id=data-eng-446809-terra-bucket]
google_bigquery_dataset.demo_dataset: Creation complete after 3s [id=projects/data-eng-446809/datasets/demo_dataset]
```
