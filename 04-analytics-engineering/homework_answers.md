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

