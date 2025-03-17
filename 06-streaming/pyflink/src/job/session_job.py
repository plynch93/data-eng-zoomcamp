from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, DataTypes, TableEnvironment, StreamTableEnvironment
from pyflink.common.watermark_strategy import WatermarkStrategy
from pyflink.common.time import Duration

def create_taxi_events_sink_postgres(t_env):
    table_name = 'green_taxi_trips'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            lpep_pickup_datetime TIMESTAMP(3),
            lpep_dropoff_datetime TIMESTAMP(3),
            PULocationID BIGINT,
            DOLocationID BIGINT,
            passenger_count INTEGER,
            trip_distance INTEGER,
            tip_amount FLOAT,
            PRIMARY KEY (lpep_pickup_datetime, PULocationID, DOLocationID) NOT ENFORCED
        ) WITH (
            'connector' = 'jdbc',
            'url' = 'jdbc:postgresql://postgres:5432/postgres',
            'table-name' = '{table_name}',
            'username' = 'postgres',
            'password' = 'postgres',
            'driver' = 'org.postgresql.Driver'
        );
        """
    t_env.execute_sql(sink_ddl)
    return table_name

def create_events_aggregated_sink(t_env):
    table_name = 'processed_events_aggregated'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            event_hour TIMESTAMP(3),
            PULocationID BIGINT,
            DOLocationID BIGINT,
            num_hits BIGINT,
            PRIMARY KEY (event_hour, PULocationID, DOLocationID) NOT ENFORCED
        ) WITH (
            'connector' = 'jdbc',
            'url' = 'jdbc:postgresql://postgres:5432/postgres',
            'table-name' = '{table_name}',
            'username' = 'postgres',
            'password' = 'postgres',
            'driver' = 'org.postgresql.Driver'
        );
        """
    t_env.execute_sql(sink_ddl)
    return table_name

def create_events_source_kafka(t_env):
    table_name = "green_taxi"
    source_ddl = f"""
        CREATE TABLE {table_name} (
            lpep_pickup_datetime STRING,
            lpep_dropoff_datetime STRING,
            PULocationID BIGINT,
            DOLocationID BIGINT,
            passenger_count INTEGER,
            trip_distance INTEGER,
            tip_amount FLOAT,
            pickup_time AS CAST(lpep_pickup_datetime AS TIMESTAMP(3)),
            session_time AS CAST(lpep_pickup_datetime AS TIMESTAMP(3)),
            event_time AS CAST(lpep_dropoff_datetime AS TIMESTAMP(3)),
            WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = 'redpanda-1:29092',
            'topic' = 'green-trips',
            'scan.startup.mode' = 'earliest-offset',
            'properties.auto.offset.reset' = 'earliest',
            'format' = 'json',
            'json.ignore-parse-errors' = 'true'
        );
        """
    t_env.execute_sql(source_ddl)
    return table_name


def log_aggregation():
    # Set up the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.enable_checkpointing(10 * 1000)
    env.set_parallelism(3)

    # Set up the table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)

    watermark_strategy = (
        WatermarkStrategy
        .for_bounded_out_of_orderness(Duration.of_seconds(5))
        .with_timestamp_assigner(
            # This lambda is your timestamp assigner:
            #   event -> The data record
            #   timestamp -> The previously assigned (or default) timestamp
            lambda event, timestamp: event[2]  # We treat the second tuple element as the event-time (ms).
        )
    )
    try:
        # Create tables
        source_table = create_events_source_kafka(t_env)
        aggregated_table = create_events_aggregated_sink(t_env)
        raw_table = create_taxi_events_sink_postgres(t_env)

        # Insert raw records
        t_env.execute_sql(f"""
        INSERT INTO {raw_table}
        SELECT 
            CAST(lpep_pickup_datetime AS TIMESTAMP(3)) as lpep_pickup_datetime,
            CAST(lpep_dropoff_datetime AS TIMESTAMP(3)) as lpep_dropoff_datetime,
            PULocationID,
            DOLocationID,
            passenger_count,
            trip_distance,
            tip_amount
        FROM {source_table}
        """).wait()

        # Original aggregation query
        t_env.execute_sql(f"""
        INSERT INTO {aggregated_table}
        SELECT
            window_start AS event_hour,
            PULocationID,
            DOLocationID,
            COUNT(*) AS num_trips
        FROM TABLE(
            TUMBLE(
                TABLE {source_table},
                DESCRIPTOR(event_time),
                INTERVAL '5' MINUTE
            )
        )
        GROUP BY window_start, event_time, PULocationID, DOLocationID;
        """).wait()

    except Exception as e:
        print("Writing records from Kafka to JDBC failed:", str(e))


if __name__ == '__main__':
    log_aggregation()