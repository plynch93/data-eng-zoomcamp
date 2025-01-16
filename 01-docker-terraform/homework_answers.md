This file contains the workings and answers for `Module 1 - Docker, SQL and Terraform`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/01-docker-terraform/homework.md).

## Docker and SQL

### Question 1. Understanding docker first run
Use docker to run an image of python 3.12.8 in interactive mode with the entrypoint of bash.
Command ran:
```bash
docker run -it --entrypoint bash python:3.12.8
```
Once running connect to `localhost:8080`, login with credentials from yml file. Click Servers -> Register -> Server and enter details to connect to the Postgres server

 - `-i` - interactive mode
 - `-t` - creates a terminal interface allowing interaction (like a shell prompt)
 - `--entrypoint bash` - Overwrites the dafault entrypoint (python) with bash

Using `pip list` get version of installed python packages.

|Package    |Version |
|---------- |------- |
|pip        |24.3.1 |


**Question:**
What's the version of pip in the image?

**Answer:**
24.3.1

### Question 2. Understanding Docker networking and docker-compose
Using this [docker-compose](docker-compose.yml) file, launch postgres and pgadmin.
```bash
docker-compose up -d
```

**Question:**
What is the hostname and port that pgadmin should use to connect to the postgres database?

**Answer:**
db:5432


## Postgres setup
1. Use docker compose to start postgres and pgadmin, using the `docker-compose` file [here](docker/docker-compose.yaml).
```shell
docker-compose up -d
```
The existing yellow_taxi_trips should still be populated as reusing mount
2. Use jupyter notebook to inspect `green_tripdata`. Made changes to `ingest_data.py` script to make it more generic and move specfic mapping rules to additional functions.
3. Ingest `green_taxi_trips` with the python ingest script, ingest_data.py.
```shell
URL=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz

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
URL=https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv

python ingest_data.py \
  --user=root \
  --password=root \
  --host=localhost \
  --port=5432 \
  --db=ny_taxi \
  --table_name=zones \
  --url=${URL}
```

### Question 3. Trip Segmentation Count
During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:

Up to 1 mile
In between 1 (exclusive) and 3 miles (inclusive),
In between 3 (exclusive) and 7 miles (inclusive),
In between 7 (exclusive) and 10 miles (inclusive),
Over 10 miles

Example SQL query for single bucket:
```sql
SELECT 
	COUNT(1) 
FROM 
	green_taxi_trips
WHERE
    date >= '2019-10-01' AND
	date < '2019-11-01' AND
	trip_distance > 3.0 AND
	trip_distance <= 7.0
```



<details>
    <summary>SQL query to create bucket for all values:</summary>

```sql
    SELECT 
        CASE
            WHEN trip_distance <= 1 THEN '<1'
            WHEN trip_distance > 1 AND trip_distance <= 3 THEN '1-3'
            WHEN trip_distance > 3 AND trip_distance <= 7 THEN '3-7'
            WHEN trip_distance > 7 AND trip_distance <= 10 THEN '7-10'
            ELSE '10+'
        END AS bucket,
        COUNT(*) AS count
    FROM 
        green_taxi_trips
    WHERE 
        pickup_date >= '2019-10-01' AND
        dropoff_date < '2019-11-01'
    GROUP BY bucket;
```
</details>

**Answers:**    
|Bucket	|Count|
|-------|-----|
|<1	    | 104802 |
|1-3	| 198924 |
|3-7	| 109603 |
|7-10   | 27678  |
|10+	| 35189  |

104,802; 198,924; 109,603; 27,678; 35,189

### Question 4. Longest trip for each day

<details>
    <summary>SQL query to get max trip distance for each date:</summary>

```sql
SELECT 
	MAX(trip_distance) AS max_distance,
	pickup_date
FROM 
    green_taxi_trips
GROUP BY 
    pickup_date
ORDER BY 
    max_distance DESC
LIMIT 5;
```
</details>


**Question:**
Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.

**Answer:**
2019-10-31

### Question 5. Three biggest pickup zones

<details>
    <summary>SQL query to sum total amount by zone:</summary>

```sql
WITH agg_results AS (
	SELECT 
		SUM(trips.total_amount) AS sum_amount,
		zones.zone AS zone
	FROM 
		green_taxi_trips trips
	INNER JOIN 
		zones ON trips.pulocationid=zones.locationid
	WHERE 
		pickup_date = '2019-10-18'
	GROUP BY 
		zone
)
SELECT
	sum_amount,
	zone
FROM
	agg_results
WHERE 
	sum_amount > 13000
ORDER BY
	sum_amount DESC;
```
</details>


**Question:**
Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?
Consider only lpep_pickup_datetime when filtering by date

**Answer:**
|Total Amount | Zone |
| ----------|------|   
|18686.68	| East Harlem North |
|16797.26	| East Harlem South |
|13029.79	| Morningside Heights |

East Harlem North, East Harlem South, Morningside Heights

### Question 6. Largest tip

Needed two joins, to get pickup and dropoff locations

<details>
    <summary>SQL query to find largest tip and zone:</summary>

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
	trips.pickup_date >= '2019-10-01' AND 
	trips.dropoff_date < '2019-11-01' AND
	pickup_zones.zone = 'East Harlem North'
GROUP BY
	dropoff_zones.zone
ORDER BY
	max_tip DESC
LIMIT 5
```
</details>

**Question:**
For the passengers picked up in Ocrober 2019 in the zone name East Harlem North which was the drop off zone that had the largest tip?

**Answer:**
| Max Tip |	Zone |
| --------|------|
| 87.3 |	JFK Airport |
| 80.88 |	Yorkville West |
| 40 |	East Harlem North |
| 26.45 |	Newark Airport |
| 18.45 |	Upper East Side North |

### Question 7. Terraform Workflow

 - `terraform init`
 ```
  Initialize a new or existing Terraform working directory by creating
  initial files, loading any remote state, downloading modules, etc.

  This is the first command that should be run for any new or existing
  Terraform configuration per machine. This sets up all the local data
  necessary to run Terraform that is typically not committed to version
  control.
 ``` 
 - `terraform import`
 ```
  Import existing infrastructure into your Terraform state.

  This will find and import the specified resource into your Terraform
  state, allowing existing infrastructure to come under Terraform
  management without having to be initially created by Terraform.
 ```

 - `terraform plan`
 ```
  Generates a speculative execution plan, showing what actions Terraform
  would take to apply the current configuration. This command will not
  actually perform the planned actions.
 ```
 - `terraform apply`
 ```
  Creates or updates infrastructure according to Terraform configuration
  files in the current directory.

  By default, Terraform will generate a new plan and present it for your
  approval before taking any action.

  Options:

  -auto-approve          Skip interactive approval of plan before applying.
 ```

 - `terraform destroy`
 ```
 Destroy Terraform-managed infrastructure.
 ```

**Question:**
Which of the following sequences, respectively, describes the workflow for:

Downloading the provider plugins and setting up backend,
Generating proposed changes and auto-executing the plan
Remove all resources managed by terraform`

**Answer:**
terraform init, terraform apply -auto-aprove, terraform destroy