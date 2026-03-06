SELECT
    CAST(START AS DATE)     AS condition_start,
    CAST(STOP AS DATE)      AS condition_stop,
    PATIENT                 AS patient_id,
    ENCOUNTER               AS encounter_id,
    CODE                    AS code,
    DESCRIPTION             AS description
FROM {{ source('synthea', 'conditions') }}
