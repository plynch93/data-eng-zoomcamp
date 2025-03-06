This file contains the workings and answers for `Module 5 - Batch`.
Questions can be found [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2025/05-batch/homework.md).

For the below questions pyspark was used in areas where SQL could have been used as a learning experience. All working can be found in the Jupyter notebook [here](batch_homework.ipynb).

## Setup
Using a VM hosted in GCP which has been deployed using terraform, the configuration can be found in the [main.tf](setup/main.tf) file. On startup the VM will run a script to install the required software which can be found [here](setup/startup_script.sh).

### Question 1: Install Spark and PySpark

 - Install Spark
 - Run PySpark
 - Create a local spark session
 - Execute spark.version.

What's the output?

Using jupyter notebooks a spark session was started with:
```python
import pyspark
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('ny_taxi') \
    .getOrCreate()
```

**Answer**
3.3.2

### Question 2: Yellow October 2024
Read the October 2024 Yellow into a Spark Dataframe.

Repartition the Dataframe to 4 partitions and save it to parquet.

What is the average size of the Parquet (ending with .parquet extension) Files that were created (in MB)? Select the answer which most closely matches.

1. Read into a spark dataframe
```python
df = spark.read.parquet('yellow_tripdata_2024-10.parquet')
```
2. Repartition to 4 partitions:
```python
df = df.repartition(4)
```
3. Write to parquet
```python
df.write.parquet('/tmp/yellow/2024/10/')
```


```
└── [4.0K]  yellow
    └── [4.0K]  2024
        └── [4.0K]  10
            ├── [   0]  _SUCCESS
            ├── [ 24M]  part-00000-b199f7f5-a43a-4cf5-89ff-ef73f844daad-c000.snappy.parquet
            ├── [ 24M]  part-00001-b199f7f5-a43a-4cf5-89ff-ef73f844daad-c000.snappy.parquet
            ├── [ 24M]  part-00002-b199f7f5-a43a-4cf5-89ff-ef73f844daad-c000.snappy.parquet
            └── [ 24M]  part-00003-b199f7f5-a43a-4cf5-89ff-ef73f844daad-c000.snappy.parquet
```

**Answer**
24MB using tree
25MB using ls -lh

### Question 3: Count records
How many taxi trips were there on the 15th of October?

Consider only trips that started on the 15th of October.

```python
from pyspark.sql import functions as F

df = df \
    .withColumn('pickup_date', F.to_date(df.tpep_pickup_datetime)) \
    .withColumn('dropoff_date', F.to_date(df.tpep_dropoff_datetime)) 

df.filter( \
    (df.pickup_date == '2024-10-15') & (df.dropoff_date == '2024-10-15')) \
    .count()
```

**Answer**
127,993

### Question 4: Longest trip
What is the length of the longest trip in the dataset in hours?

```python
# Create a new trip duration column in seconds
df = df.withColumn('trip_duration', (F.col('tpep_dropoff_datetime') - F.col('tpep_pickup_datetime')).cast('long'))
# Get the max in hours
df.select((F.max('trip_duration'))/3600).show()
```

**Answer**
162.6

### Question 5: User Interface
Spark’s User Interface which shows the application's dashboard runs on which local port?

**Answer**
4040

### Question 6: Least frequent pickup location zone
Load the zone lookup data into a temp view in Spark.

```python
# Load the zones data into a df
df_zone = spark.read.csv('taxi_zone_lookup.csv', header = 'True', inferSchema = 'True')
# Join the trips df to the zone df
df = df.join(df_zone, df.PULocationID == df_zone.LocationID)
# import functions for aggregation
from pyspark.sql.functions import count, desc, asc
# Get count by zone
df.groupBy('Zone') \
  .agg(count('*').alias('Count')) \
  .sort(asc('Count')) \
  .show()
```

**Answer**
Governor's Island/Ellis Island/Liberty Island