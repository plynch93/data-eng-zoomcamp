import re
import pandas as pd

def process_yellow_taxi(df):
    """Apply data processing for the yellow taxi data

    Args:
        df (pandas dataframe): _description_
    """
    print("Processing yellow_taxi data")

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    return df

def process_green_taxi(df):
    """Apply data processing for the green taxi data

    Args:
        df (pandas dataframe): _description_
    """
    print("Processing green_taxi data")

    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
    return df

def process_zones(df):
    """Apply data processing for the yellow taxi data

    Args:
        df (pandas dataframe): _description_
    """
    print("Processing yellow_taxi data")

    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
    return df

file_processing_map = [
    (r"^green_tripdata.*\.csv.gz$", process_green_taxi),
    (r"^yellow_tripdata.*\.csv.gz$", process_yellow_taxi)
]

def process_file(file_name, df):
    """Use the file name to determine the processing function
       to apply to the dataframe.

    Args:
        file_name (_type_): _description_
        df (_type_): _description_
    """

    for pattern, function in file_processing_map:
        if re.match(pattern, file_name):
            return function(df)
                
    print(f"No additional processing rules defined for {file_name}")
    return df