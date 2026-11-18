-- ============================================
-- 2. AIRLINE-WISE PERFORMANCE
-- ============================================

CREATE OR REFRESH MATERIALIZED VIEW gold_airline_performance AS

SELECT
    airline,

    COUNT(*) AS total_flights,

    SUM(passengers) AS total_passengers,

    ROUND(AVG(avg_fare), 2) AS average_fare,

    SUM(ticket_revenue) AS total_revenue,

    ROUND(AVG(delay_minutes), 2) AS average_delay,

    SUM(
        CASE
            WHEN delay_category <> 'On Time'
            THEN 1
            ELSE 0
        END
    ) AS delayed_flights

FROM silver_flights_clean

GROUP BY airline;

CREATE OR REFRESH MATERIALIZED VIEW gold_route_summary AS

SELECT
    origin_city,

    destination_city,

    COUNT(*) AS total_flights,

    SUM(passengers) AS total_passengers,

    ROUND(AVG(distance_km), 2) AS average_distance_km,

    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes,

    SUM(ticket_revenue) AS total_revenue,

    SUM(
        CASE
            WHEN delay_category IN ('Minor Delay', 'Major Delay')
            THEN 1
            ELSE 0
        END
    ) AS delayed_flights

FROM silver_flights_clean

GROUP BY
    origin_city,
    destination_city;

CREATE OR REFRESH MATERIALIZED VIEW gold_delay_summary AS

SELECT
    delay_category,

    COUNT(*) AS total_flights,

    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes,

    MAX(delay_minutes) AS maximum_delay_minutes,

    SUM(passengers) AS total_passengers,

    SUM(ticket_revenue) AS total_revenue

FROM silver_flights_clean

GROUP BY delay_category;


CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS

WITH bronze_stats AS (

    SELECT
        COUNT(*) AS total_bronze_records,

        COUNT(DISTINCT flight_id) AS unique_flight_ids,

        -- 1. Missing delay minutes
        SUM(
            CASE WHEN delay_minutes IS NULL
            THEN 1 ELSE 0 END
        ) AS missing_delay_minutes_rows,

        -- 2. Missing ticket revenue
        SUM(
            CASE WHEN ticket_revenue IS NULL
            THEN 1 ELSE 0 END
        ) AS missing_ticket_revenue_rows,

        -- 3. Missing delay reason
        SUM(
            CASE WHEN delay_reason IS NULL
                      OR TRIM(delay_reason) = ''
            THEN 1 ELSE 0 END
        ) AS missing_delay_reason_rows,

        -- 4. Passengers greater than seats
        SUM(
            CASE WHEN passengers > seat_capacity
            THEN 1 ELSE 0 END
        ) AS overbooked_rows,

        -- 5. Missing airline
        SUM(
            CASE WHEN airline IS NULL
                      OR TRIM(airline) = ''
            THEN 1 ELSE 0 END
        ) AS missing_airline_rows

    FROM bronze_airline_flights

),

silver_stats AS (

    SELECT
        COUNT(*) AS clean_records
    FROM silver_flights_clean

),

rejected_stats AS (

    SELECT
        COUNT(*) AS rejected_records
    FROM silver_flights_rejected

)

SELECT

    b.total_bronze_records,

    b.unique_flight_ids,

    b.total_bronze_records - b.unique_flight_ids
        AS duplicate_records,

    s.clean_records,

    r.rejected_records,

    b.total_bronze_records
        - s.clean_records
        - r.rejected_records
        - (b.total_bronze_records - b.unique_flight_ids)
        AS unaccounted_records,

    -- Data quality issue counts
    b.missing_delay_minutes_rows,

    b.missing_ticket_revenue_rows,

    b.missing_delay_reason_rows,

    b.overbooked_rows,

    b.missing_airline_rows

FROM bronze_stats b

CROSS JOIN silver_stats s

CROSS JOIN rejected_stats r;
