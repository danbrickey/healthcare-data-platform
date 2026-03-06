SELECT
    CAST(DATE AS DATE)                  AS immunization_date,
    PATIENT                             AS patient_id,
    ENCOUNTER                           AS encounter_id,
    CODE                                AS code,
    DESCRIPTION                         AS description,
    CAST(BASE_COST AS DECIMAL(18, 2))   AS base_cost
FROM {{ source('synthea', 'immunizations') }}
