SELECT
    CAST(DATE AS DATE)              AS supply_date,
    PATIENT                         AS patient_id,
    ENCOUNTER                       AS encounter_id,
    CODE                            AS code,
    DESCRIPTION                     AS description,
    CAST(QUANTITY AS INTEGER)       AS quantity
FROM {{ source('synthea', 'supplies') }}
