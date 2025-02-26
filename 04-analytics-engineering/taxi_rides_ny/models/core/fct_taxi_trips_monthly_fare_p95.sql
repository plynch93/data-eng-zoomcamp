{{ config(materialized="table") }}

WITH trips_data AS (
    SELECT * 
    FROM {{ ref("fact_trips") }}
)

SELECT
*
FROM (
    SELECT 
        service_type,
        year,
        month,
        PERCENTILE_CONT(fare_amount, 0.9) OVER(PARTITION BY service_type, year, month) AS percentile90,
        PERCENTILE_CONT(fare_amount, 0.95) OVER(PARTITION BY service_type, year, month) AS percentile95,
        PERCENTILE_CONT(fare_amount, 0.97) OVER(PARTITION BY service_type, year, month) AS percentile97
    FROM trips_data
    WHERE year = 2020 AND month = 4 AND fare_amount > 0 AND trip_distance > 0 AND payment_type_description in ('Cash', 'Credit card')
    QUALIFY ROW_NUMBER() OVER (PARTITION BY service_type, year, month ORDER BY service_type) = 1
)