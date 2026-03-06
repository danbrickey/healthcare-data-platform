SELECT
    Id                                  AS organization_id,
    NAME                                AS name,
    ADDRESS                             AS address,
    CITY                                AS city,
    STATE                               AS state,
    ZIP                                 AS zip,
    CAST(LAT AS DECIMAL(10, 6))         AS latitude,
    CAST(LON AS DECIMAL(10, 6))         AS longitude,
    PHONE                               AS phone,
    CAST(REVENUE AS DECIMAL(18, 2))     AS revenue,
    CAST(UTILIZATION AS INTEGER)        AS utilization
FROM {{ source('synthea', 'organizations') }}
