WITH hub AS (
    SELECT
        hk_patient AS patient_key,
        patient_id,
        load_date,
        record_source
    FROM {{ ref('h_patient') }}
),

sat_ranked AS (
    SELECT
        hk_patient,
        first_name,
        last_name,
        birth_date,
        death_date,
        gender,
        race,
        ethnicity,
        marital_status,
        ROW_NUMBER() OVER (
            PARTITION BY hk_patient
            ORDER BY load_date DESC
        ) AS rn
    FROM {{ ref('s_patient_demographics') }}
),

sat_latest AS (
    SELECT * FROM sat_ranked WHERE rn = 1
)

SELECT
    h.patient_key,
    h.patient_id,
    s.first_name || ' ' || s.last_name AS full_name,
    s.first_name,
    s.last_name,
    s.birth_date,
    s.death_date,
    s.gender,
    s.race,
    s.ethnicity,
    s.marital_status,
    CASE WHEN s.death_date IS NOT NULL THEN TRUE ELSE FALSE END AS is_deceased,
    h.record_source
FROM hub h
LEFT JOIN sat_latest s
    ON h.patient_key = s.hk_patient
