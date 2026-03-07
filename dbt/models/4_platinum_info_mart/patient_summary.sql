WITH patients AS (
    SELECT * FROM {{ ref('dim_patient') }}
),

encounters AS (
    SELECT
        patient_key,
        COUNT(*) AS total_encounters,
        COUNT(DISTINCT encounter_class) AS distinct_encounter_types,
        MIN(encounter_date) AS first_encounter_date,
        MAX(encounter_date) AS last_encounter_date,
        SUM(total_claim_cost) AS total_claim_cost,
        SUM(payer_coverage) AS total_payer_coverage,
        SUM(out_of_pocket_cost) AS total_out_of_pocket_cost
    FROM {{ ref('fct_encounter') }}
    GROUP BY patient_key
),

conditions AS (
    SELECT
        patient_key,
        COUNT(*) AS total_conditions,
        COUNT(DISTINCT condition_code) AS distinct_conditions
    FROM {{ ref('fct_condition') }}
    GROUP BY patient_key
),

medications AS (
    SELECT
        patient_key,
        COUNT(*) AS total_medications,
        COUNT(DISTINCT medication_code) AS distinct_medications,
        SUM(total_cost) AS total_medication_cost
    FROM {{ ref('fct_medication') }}
    GROUP BY patient_key
)

SELECT
    p.patient_id,
    p.full_name,
    p.gender,
    p.race,
    p.ethnicity,
    p.birth_date,
    p.death_date,
    p.is_deceased,
    p.marital_status,
    COALESCE(e.total_encounters, 0) AS total_encounters,
    COALESCE(e.distinct_encounter_types, 0) AS distinct_encounter_types,
    e.first_encounter_date,
    e.last_encounter_date,
    COALESCE(e.total_claim_cost, 0) AS total_claim_cost,
    COALESCE(e.total_payer_coverage, 0) AS total_payer_coverage,
    COALESCE(e.total_out_of_pocket_cost, 0) AS total_out_of_pocket_cost,
    COALESCE(c.total_conditions, 0) AS total_conditions,
    COALESCE(c.distinct_conditions, 0) AS distinct_conditions,
    COALESCE(m.total_medications, 0) AS total_medications,
    COALESCE(m.distinct_medications, 0) AS distinct_medications,
    COALESCE(m.total_medication_cost, 0) AS total_medication_cost
FROM patients p
LEFT JOIN encounters e
    ON p.patient_key = e.patient_key
LEFT JOIN conditions c
    ON p.patient_key = c.patient_key
LEFT JOIN medications m
    ON p.patient_key = m.patient_key
