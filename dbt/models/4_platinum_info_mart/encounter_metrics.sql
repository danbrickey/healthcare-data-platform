WITH encounters AS (
    SELECT * FROM {{ ref('fct_encounter') }}
)

SELECT
    encounter_class,
    COUNT(*) AS encounter_count,
    COUNT(DISTINCT patient_key) AS unique_patients,
    ROUND(AVG(total_claim_cost), 2) AS avg_claim_cost,
    ROUND(AVG(payer_coverage), 2) AS avg_payer_coverage,
    ROUND(AVG(out_of_pocket_cost), 2) AS avg_out_of_pocket_cost,
    SUM(total_claim_cost) AS total_claim_cost,
    SUM(payer_coverage) AS total_payer_coverage,
    MIN(encounter_date) AS earliest_encounter,
    MAX(encounter_date) AS latest_encounter
FROM encounters
GROUP BY encounter_class
ORDER BY encounter_count DESC
