This file contains the workings and answers for `Module 4 - Analytics Engineering`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/04-analytics-engineering/homework.md).

## Setup
The tables necessary for this work are created as external tables in BigQuery which read directly from GCS

### Upload files to GCS
The following data sets were needed to complete the homework:
* [Green Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/green)
* [Yellow Taxi dataset (2019 and 2020)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/yellow)
* [For Hire Vehicle dataset (2019)](https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv)

The datasets were uploaded to GCS using a Kestra flow developed during the workflow orchestration section of the course. The flow was modified to include fhv and can be found [here](/data-eng-zoomcamp/02-workflow-orchestration/kestra/flows/gcp_taxi_multi_months.yaml) with instructions on running Kestra [here](/data-eng-zoomcamp/02-workflow-orchestration/README.md).

### Create external tables
A python script, [create_bq_tables.py](create_bq_tables.py), was used to create the external tables in BigQuery. As the source files were CSVs and Parquet or Arvo it meant that the schemas had to be created for the external tables. This was done by reading the first 100 rows of each dataset into a pandas dataframe and inferring the datatypes.
The script takes no inputs and can be ran with:
```bash
python create_bq_tables.py
```

### Question 1: Understanding dbt model resolution

Provided you've got the following sources.yaml
```yaml
version: 2

sources:
  - name: raw_nyc_tripdata
    database: "{{ env_var('DBT_BIGQUERY_PROJECT', 'dtc_zoomcamp_2025') }}"
    schema:   "{{ env_var('DBT_BIGQUERY_SOURCE_DATASET', 'raw_nyc_tripdata') }}"
    tables:
      - name: ext_green_taxi
      - name: ext_yellow_taxi
```

with the following env variables setup where `dbt` runs:
```shell
export DBT_BIGQUERY_PROJECT=myproject
export DBT_BIGQUERY_DATASET=my_nyc_tripdata
```

What does this .sql model compile to?
```sql
select * 
from {{ source('raw_nyc_tripdata', 'ext_green_taxi' ) }}
```

**Answer:**
`select * from myproject.raw_nyc_tripdata.ext_green_taxi`

If a environment variable already exists then DBT will use that value, otherwise it will use the value from the sources.yaml.

### Question 2: dbt Variables & Dynamic Models

Say you have to modify the following dbt_model (`fct_recent_taxi_trips.sql`) to enable Analytics Engineers to dynamically control the date range. 

- In development, you want to process only **the last 7 days of trips**
- In production, you need to process **the last 30 days** for analytics

```sql
select *
from {{ ref('fact_taxi_trips') }}
where pickup_datetime >= CURRENT_DATE - INTERVAL '30' DAY
```

What would you change to accomplish that in a such way that command line arguments takes precedence over ENV_VARs, which takes precedence over DEFAULT value?

**Answer**
The following was the answer I used to query my records.
```sql
SELECT *
FROM {{ ref('fact_trips') }}
WHERE pickup_datetime >= TIMESTAMP('2019-02-01' - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY)
```
Run with `dbt run --select fct_recent_taxi_trips --vars '{days_back: 10}'`

The equivalent answer from the list was:
```
Update the WHERE clause to pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY
```

### Question 3: dbt Data Lineage and Execution


**Answer**
`dbt run --select models/staging/+`
Explanation, this will run all staging models and all downstream dependencies.

### Question 4: dbt Macros and Jinja
Best to refer to the original question [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/04-analytics-engineering/homework.md).
Select all statements that are true to the models using the `resolve_schema` macro:
 - Setting a value for DBT_BIGQUERY_TARGET_DATASET env var is mandatory, or it'll fail to compile
 - ~~Setting a value for DBT_BIGQUERY_STAGING_DATASET env var is mandatory, or it'll fail to compile~~
 - When using core, it materializes in the dataset defined in DBT_BIGQUERY_TARGET_DATASET
 - When using stg, it materializes in the dataset defined in DBT_BIGQUERY_STAGING_DATASET, or defaults to DBT_BIGQUERY_TARGET_DATASET
 - When using staging, it materializes in the dataset defined in DBT_BIGQUERY_STAGING_DATASET, or defaults to DBT_BIGQUERY_TARGET_DATASET

### Question 5: Taxi Quarterly Revenue Growth

1. Create a new model `fct_taxi_trips_quarterly_revenue.sql`
2. Compute the Quarterly Revenues for each year for based on `total_amount`
3. Compute the Quarterly YoY (Year-over-Year) revenue growth 
  * e.g.: In 2020/Q1, Green Taxi had -12.34% revenue growth compared to 2019/Q1
  * e.g.: In 2020/Q4, Yellow Taxi had +34.56% revenue growth compared to 2019/Q4

Considering the YoY Growth in 2020, which were the yearly quarters with the best (or less worse) and worst results for green, and yellow

**Answer**
green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}

### Question 6: P97/P95/P90 Taxi Monthly Fare

1. Create a new model `fct_taxi_trips_monthly_fare_p95.sql`
2. Filter out invalid entries (`fare_amount > 0`, `trip_distance > 0`, and `payment_type_description in ('Cash', 'Credit Card')`)
3. Compute the **continous percentile** of `fare_amount` partitioning by service_type, year and and month

Now, what are the values of `p97`, `p95`, `p90` for Green Taxi and Yellow Taxi, in April 2020?

**Answer**
green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}

### Question 7: Top #Nth longest P90 travel time Location for FHV

1. Create a new model `fct_fhv_monthly_zone_traveltime_p90.sql`
2. For each record in `dim_fhv_trips.sql`, compute the [timestamp_diff](https://cloud.google.com/bigquery/docs/reference/standard-sql/timestamp_functions#timestamp_diff) in seconds between dropoff_datetime and pickup_datetime - we'll call it `trip_duration` for this exercise
3. Compute the **continous** `p90` of `trip_duration` partitioning by year, month, pickup_location_id, and dropoff_location_id

For the Trips that **respectively** started from `Newark Airport`, `SoHo`, and `Yorkville East`, in November 2019, what are **dropoff_zones** with the 2nd longest p90 trip_duration ?
**Answer**
LaGuardia Airport, Chinatown, Garment District