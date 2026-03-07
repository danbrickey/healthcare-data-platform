WITH conditions AS (
    SELECT * FROM {{ ref('fct_condition') }}
),

encounters AS (
    SELECT
        encounter_key,
        encounter_class
    FROM {{ ref('fct_encounter') }}
)

SELECT
    c.condition_code,
    c.condition_description,
    COUNT(*) AS condition_count,
    COUNT(DISTINCT c.patient_key) AS unique_patients,
    ROUND(AVG(c.duration_days), 1) AS avg_duration_days,
    MIN(c.condition_start) AS earliest_diagnosis,
    MAX(c.condition_start) AS latest_diagnosis
FROM conditions c
LEFT JOIN encounters e
    ON c.encounter_key = e.encounter_key
GROUP BY c.condition_code, c.condition_description
ORDER BY condition_count DESC
