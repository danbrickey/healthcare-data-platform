WITH conditions AS (
    SELECT
        hk_patient_encounter_condition AS condition_key,
        hk_patient AS patient_key,
        hk_encounter AS encounter_key,
        code AS condition_code,
        description AS condition_description,
        condition_start,
        condition_stop,
        CASE
            WHEN condition_stop IS NOT NULL
            THEN condition_stop - condition_start
        END AS duration_days,
        record_source
    FROM {{ ref('stg_synthea__conditions_hashed') }}
)

SELECT * FROM conditions
