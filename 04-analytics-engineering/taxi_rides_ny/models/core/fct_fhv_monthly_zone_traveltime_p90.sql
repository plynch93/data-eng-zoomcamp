{{ config(materialized="table") }}

WITH fhv_data AS (
    SELECT *,
    TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration
    FROM {{ ref("dim_fhv_trips") }}
)

SELECT
    year,
    month,
    pickup_locationid,
    dropoff_locationid,
    pickup_zone,
    dropoff_zone,
    PERCENTILE_CONT(trip_duration, 0.9) OVER(PARTITION BY year, month, pickup_locationid, dropoff_locationid) AS percentile90,
    FROM fhv_data
    WHERE 
        year = 2019 AND 
        month = 11 AND
        pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
    QUALIFY ROW_NUMBER() OVER (PARTITION BY year, month, pickup_locationid, dropoff_locationid ORDER BY pickup_locationid) = 1
    ORDER BY pickup_zone, percentile90 DESC
    