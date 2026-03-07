SELECT
    CAST(START AS TIMESTAMP)                    AS medication_start_ts,
    CAST(START AS DATE)                         AS medication_start,
    CAST(STOP AS DATE)                          AS medication_stop,
    PATIENT                                     AS patient_id,
    PAYER                                       AS payer_id,
    ENCOUNTER                                   AS encounter_id,
    CODE                                        AS code,
    DESCRIPTION                                 AS description,
    CAST(BASE_COST AS DECIMAL(18, 2))           AS base_cost,
    CAST(PAYER_COVERAGE AS DECIMAL(18, 2))      AS payer_coverage,
    CAST(DISPENSES AS INTEGER)                  AS dispenses,
    CAST(TOTALCOST AS DECIMAL(18, 2))           AS total_cost,
    REASONCODE                                  AS reason_code,
    REASONDESCRIPTION                           AS reason_description
FROM {{ source('synthea', 'medications') }}
