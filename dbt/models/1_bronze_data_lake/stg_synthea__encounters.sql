SELECT
    Id                                          AS encounter_id,
    CAST(START AS TIMESTAMP)                    AS encounter_start,
    CAST(STOP AS TIMESTAMP)                     AS encounter_stop,
    PATIENT                                     AS patient_id,
    ORGANIZATION                                AS organization_id,
    PROVIDER                                    AS provider_id,
    PAYER                                       AS payer_id,
    ENCOUNTERCLASS                              AS encounter_class,
    CODE                                        AS code,
    DESCRIPTION                                 AS description,
    CAST(BASE_ENCOUNTER_COST AS DECIMAL(18, 2)) AS base_encounter_cost,
    CAST(TOTAL_CLAIM_COST AS DECIMAL(18, 2))    AS total_claim_cost,
    CAST(PAYER_COVERAGE AS DECIMAL(18, 2))      AS payer_coverage,
    REASONCODE                                  AS reason_code,
    REASONDESCRIPTION                           AS reason_description
FROM {{ source('synthea', 'encounters') }}
