import os
import pandas as pd
from google.cloud import bigquery

# Define variables
project_id = os.getenv("GCP_PROJECT_ID")
bucket_name = os.getenv("GCP_BUCKET_NAME")
dataset_name = "ny_taxi_rides"  # Replace with your dataset name
table_names = ["green", "yellow", "fhv"]

# Initialize BigQuery client
client = bigquery.Client()

def infer_schema_from_csv(file_path):
    df = pd.read_csv(file_path, nrows=100)
    schema = []
    for column, dtype in zip(df.columns, df.dtypes):
        if pd.api.types.is_integer_dtype(dtype):
            bigquery_type = "INTEGER"
        elif pd.api.types.is_float_dtype(dtype):
            bigquery_type = "FLOAT"
        elif pd.api.types.is_bool_dtype(dtype):
            bigquery_type = "BOOLEAN"
        else:
            bigquery_type = "STRING"
        schema.append(bigquery.SchemaField(column, bigquery_type))
    return schema

for table_name in table_names:
    # Construct full table ID
    table_id = f"{project_id}.{dataset_name}.external_{table_name}_trips"
    gcs_uris = [
        f"gs://{bucket_name}/{table_name}_tripdata_2019*.csv",  # GCS file pattern
        f"gs://{bucket_name}/{table_name}_tripdata_2020*.csv",
    ]
    sample_file_path = f"gs://{bucket_name}/{table_name}_tripdata_2019-01.csv"

    # Infer schema from a sample CSV file
    schema = infer_schema_from_csv(sample_file_path)

    # Configure external table
    external_config = bigquery.ExternalConfig("CSV")
    external_config.source_uris = [gcs_uris]
    external_config.schema = schema
    external_config.options.skip_leading_rows = 1  # Skip header row
    external_config.options.field_delimiter = ","

    # Create table object
    table = bigquery.Table(table_id)
    table.external_data_configuration = external_config

    # Create or replace the table
    client.create_table(table, exists_ok=True)

    print(f"External table {table_id} created successfully.")
