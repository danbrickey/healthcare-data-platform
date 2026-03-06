SELECT
    Id                      AS careplan_id,
    CAST(START AS DATE)     AS careplan_start,
    CAST(STOP AS DATE)      AS careplan_stop,
    PATIENT                 AS patient_id,
    ENCOUNTER               AS encounter_id,
    CODE                    AS code,
    DESCRIPTION             AS description,
    REASONCODE              AS reason_code,
    REASONDESCRIPTION       AS reason_description
FROM {{ source('synthea', 'careplans') }}
