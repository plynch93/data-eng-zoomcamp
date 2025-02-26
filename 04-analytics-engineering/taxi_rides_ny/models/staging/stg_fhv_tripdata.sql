{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
  from {{ source('staging','external_fhv_trips') }}
  where dispatching_base_num is not null 
)

select 
    dispatching_base_num,
    {{ dbt.safe_cast("PULocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("DOLocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,
from tripdata

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
--{% if var('is_test_run', default=true) %}

--  limit 100

-- {% endif %}