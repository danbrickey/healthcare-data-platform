SELECT
    Id                                  AS provider_id,
    ORGANIZATION                        AS organization_id,
    NAME                                AS name,
    GENDER                              AS gender,
    SPECIALITY                          AS speciality,
    ADDRESS                             AS address,
    CITY                                AS city,
    STATE                               AS state,
    ZIP                                 AS zip,
    CAST(LAT AS DECIMAL(10, 6))         AS latitude,
    CAST(LON AS DECIMAL(10, 6))         AS longitude,
    CAST(UTILIZATION AS INTEGER)        AS utilization
FROM {{ source('synthea', 'providers') }}
