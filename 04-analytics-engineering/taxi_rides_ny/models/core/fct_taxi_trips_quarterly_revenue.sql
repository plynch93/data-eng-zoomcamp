{{ config(materialized="table") }}

WITH trips_data AS (
    SELECT * 
    FROM {{ ref("fact_trips") }}
),

quarterly_data AS (
    SELECT
        service_type,
        year,
        quarter,
        -- Revenue calculation 
        SUM(fare_amount) AS revenue_quarterly_fare,
        SUM(extra) AS revenue_quarterly_extra,
        SUM(mta_tax) AS revenue_quarterly_mta_tax,
        SUM(tip_amount) AS revenue_quarterly_tip_amount,
        SUM(tolls_amount) AS revenue_quarterly_tolls_amount,
        SUM(ehail_fee) AS revenue_quarterly_ehail_fee,
        SUM(improvement_surcharge) AS revenue_quarterly_improvement_surcharge,
        SUM(total_amount) AS revenue_quarterly_total_amount,

        -- Additional calculations
        COUNT(tripid) AS total_quarterly_trips,
        AVG(passenger_count) AS avg_quarterly_passenger_count,
        AVG(trip_distance) AS avg_quarterly_trip_distance

    FROM trips_data
    GROUP BY service_type, year, quarter
),

yoy_data AS (
    SELECT
        current_data.service_type,
        current_data.year,
        current_data.quarter,
        current_data.revenue_quarterly_total_amount AS current_year_revenue,
        previous.revenue_quarterly_total_amount AS previous_year_revenue,
        CASE
            WHEN previous.revenue_quarterly_total_amount IS NULL THEN NULL  -- Avoid division by zero
            ELSE
                (
                    current_data.revenue_quarterly_total_amount - previous.revenue_quarterly_total_amount
                ) / previous.revenue_quarterly_total_amount * 100
        END AS yoy_growth_percentage
    FROM quarterly_data AS current_data
    LEFT JOIN quarterly_data AS previous
        ON current_data.service_type = previous.service_type
        AND current_data.quarter = previous.quarter
        AND current_data.year = previous.year + 1  -- Joining on previous year
)

SELECT 
    service_type, 
    year, 
    quarter, 
    current_year_revenue, 
    previous_year_revenue, 
    yoy_growth_percentage
FROM yoy_data
WHERE year=2020
ORDER BY service_type, yoy_growth_percentage
