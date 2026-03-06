SELECT
    CAST(DATE AS DATE)                      AS procedure_date,
    PATIENT                                 AS patient_id,
    ENCOUNTER                               AS encounter_id,
    CODE                                    AS code,
    DESCRIPTION                             AS description,
    CAST(BASE_COST AS DECIMAL(18, 2))       AS base_cost,
    REASONCODE                              AS reason_code,
    REASONDESCRIPTION                       AS reason_description
FROM {{ source('synthea', 'procedures') }}
