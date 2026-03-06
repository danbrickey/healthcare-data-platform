SELECT
    PATIENT                             AS patient_id,
    CAST(START_YEAR AS INTEGER)         AS start_year,
    CAST(END_YEAR AS INTEGER)           AS end_year,
    PAYER                               AS payer_id,
    OWNERSHIP                           AS ownership
FROM {{ source('synthea', 'payer_transitions') }}
