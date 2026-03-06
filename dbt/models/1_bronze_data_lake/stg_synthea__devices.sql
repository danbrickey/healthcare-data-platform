SELECT
    CAST(START AS DATE)     AS device_start,
    CAST(STOP AS DATE)      AS device_stop,
    PATIENT                 AS patient_id,
    ENCOUNTER               AS encounter_id,
    CODE                    AS code,
    DESCRIPTION             AS description,
    UDI                     AS udi
FROM {{ source('synthea', 'devices') }}
