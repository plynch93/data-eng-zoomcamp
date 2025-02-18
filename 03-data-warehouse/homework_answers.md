This file contains the workings and answers for `Module 3 - Data Warehouse`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/03-data-warehouse/homework.md).

## BIG QUERY SETUP
The script [load_yellow_taxi_data.py](load_yellow_taxi_data.py) was used in order to upload the Yellow Taxi Trip Records for January 2024 - June 2024 to a GCS bucket.

Unlike previous work the taxi data was not inserted into the `ny_taxi_wh` database. An external table was instead created which read directly from the GCS bucket.
```sql
CREATE OR REPLACE EXTERNAL TABLE `<Project ID>.ny_taxi_wh.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://<GCS bucket name>/yellow_tripdata_2024-*.parquet']
);
```

For comparisions a regular non-partitioned table was then created:
```sql
CREATE OR REPLACE TABLE <Project ID>.ny_taxi_wh.yellow_tripdata_non_partitioned AS
SELECT * FROM <Project ID>.ny_taxi_wh.external_yellow_tripdata;
```


### Question 1: 
What is count of records for the 2024 Yellow Taxi Data?

**Answer:**
20,332,093

### Question 2:
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

 - 18.82 MB for the External Table and 47.60 MB for the Materialized Table
 - 0 MB for the External Table and 155.12 MB for the Materialized Table
 - 2.14 GB for the External Table and 0MB for the Materialized Table
 - 0 MB for the External Table and 0MB for the Materialized Table

 ```sql
SELECT COUNT(DISTINCT(PULocationID)) FROM data-eng-446809.ny_taxi_wh.yellow_tripdata_non_partitioned
 ```

**Answer:**
 0 MB for the External Table and 155.12 MB for the Materialized Table

### Question 3:
 Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

**Answer:**
 BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

### Question 4:
 How many records have a fare_amount of 0?

 **Answer:**
 8,333

### Question 5:
 What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy)

 **Answer:**
Partition by tpep_dropoff_datetime and Cluster on VendorID

```sql
CREATE OR REPLACE TABLE taxi-rides-ny.nytaxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM taxi-rides-ny.nytaxi.external_yellow_tripdata;
```

### Question 6:
Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive)

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?

```sql
SELECT DISTINCT(VendorID)
FROM data-eng-446809.ny_taxi_wh.external_yellow_tripdata
WHERE DATE(tpep_pickup_datetime) BETWEEN '2024-03-01' AND '2024-03-15';
```

**Answer:**
310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

### Question 7:
Where is the data stored in the External Table you created?

**Answer:**
GCP Bucket

### Question 8:
It is best practice in Big Query to always cluster your data:

**Answer:**
False