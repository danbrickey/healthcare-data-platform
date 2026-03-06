SELECT
    CAST(DATE AS DATE)      AS observation_date,
    PATIENT                 AS patient_id,
    ENCOUNTER               AS encounter_id,
    CODE                    AS code,
    DESCRIPTION             AS description,
    VALUE                   AS value,
    UNITS                   AS units,
    TYPE                    AS type
FROM {{ source('synthea', 'observations') }}
