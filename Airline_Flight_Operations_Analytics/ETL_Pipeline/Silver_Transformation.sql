-- =====================================================
-- STEP 1: CREATE CLEAN SILVER TABLE
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW silver_flights_clean (

    CONSTRAINT valid_passengers
    EXPECT (passengers BETWEEN 0 AND seat_capacity)
    ON VIOLATION DROP ROW,

    CONSTRAINT valid_fare
    EXPECT (avg_fare >= 0)
    ON VIOLATION DROP ROW

)
AS

WITH cleaned AS (

    SELECT DISTINCT

        flight_id,
        flight_number,

        -- Clean airline name
        COALESCE(
            NULLIF(INITCAP(TRIM(airline)), ''),
            'Unknown'
        ) AS airline,

        aircraft_id,
        aircraft_type,
        flight_date,
        day_of_week,

        -- Clean city and region names
        COALESCE(
            NULLIF(INITCAP(TRIM(origin_city)), ''),
            'Unknown'
        ) AS origin_city,

        COALESCE(
            NULLIF(INITCAP(TRIM(destination_city)), ''),
            'Unknown'
        ) AS destination_city,

        COALESCE(
            NULLIF(INITCAP(TRIM(origin_region)), ''),
            'Unknown'
        ) AS origin_region,

        distance_km,
        scheduled_departure,
        actual_departure,

        -- Calculate missing delay minutes
        COALESCE(
            delay_minutes,
            TIMESTAMPDIFF(
                MINUTE,
                scheduled_departure,
                actual_departure
            )
        ) AS delay_minutes,

        -- Clean delay reason
        COALESCE(
            NULLIF(INITCAP(TRIM(delay_reason)), ''),
            'Unknown'
        ) AS delay_reason,

        seat_capacity,
        passengers,
        avg_fare,

        -- Calculate missing ticket revenue
        COALESCE(
            ticket_revenue,
            passengers * avg_fare
        ) AS ticket_revenue,

        fuel_cost,
        _rescued_data,
        source_file,
        loaded_at

    FROM bronze_airline_flights
)

-- Create delay categories
SELECT
    *,

    CASE
        WHEN delay_minutes IS NULL THEN 'Unknown'
        WHEN delay_minutes <= 15 THEN 'On Time'
        WHEN delay_minutes <= 60 THEN 'Minor Delay'
        ELSE 'Major Delay'
    END AS delay_category

FROM cleaned;


-- =====================================================
-- STEP 2: CREATE REJECTED RECORDS TABLE
-- =====================================================

CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected AS

SELECT
    *,

    CASE
        WHEN passengers < 0
            THEN 'Negative passengers'

        WHEN passengers > seat_capacity
            THEN 'Passengers exceed seat capacity'

        WHEN avg_fare < 0
            THEN 'Negative average fare'

    END AS reject_reason

FROM bronze_airline_flights

WHERE passengers < 0
   OR passengers > seat_capacity
   OR avg_fare < 0;


-- =====================================================
-- STEP 4: GOLD LAYER TRANSFORMATION
-- =====================================================
-- 1. MONTHLY FLIGHTS SUMMARY

CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_flights AS

SELECT

    DATE_TRUNC('MONTH', flight_date) AS flight_month,

    COUNT(*) AS flights,

    SUM(passengers) AS passengers,

    ROUND(
        SUM(passengers) * 100.0 /
        NULLIF(SUM(seat_capacity), 0),
        1
    ) AS load_factor_pct,

    SUM(ticket_revenue) AS ticket_revenue,

    SUM(
        CASE
            WHEN delay_category IN ('Minor Delay', 'Major Delay')
            THEN 1
            ELSE 0
        END
    ) AS delayed_flights

FROM silver_flights_clean

GROUP BY DATE_TRUNC('MONTH', flight_date);
