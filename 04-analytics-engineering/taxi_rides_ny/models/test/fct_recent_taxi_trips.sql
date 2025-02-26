SELECT *
FROM {{ ref('fact_trips') }}
WHERE pickup_datetime >= TIMESTAMP('2019-02-01' - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY)


