WITH medications AS (
    SELECT * FROM {{ ref('fct_medication') }}
)

SELECT
    medication_code,
    MAX(medication_description) AS medication_description,
    COUNT(*) AS prescription_count,
    COUNT(DISTINCT patient_key) AS unique_patients,
    SUM(dispenses) AS total_dispenses,
    ROUND(AVG(dispenses), 1) AS avg_dispenses,
    ROUND(SUM(total_cost), 2) AS total_medication_cost,
    ROUND(AVG(total_cost), 2) AS avg_medication_cost,
    ROUND(SUM(payer_coverage), 2) AS total_payer_coverage,
    ROUND(
        CASE WHEN SUM(total_cost) > 0
            THEN SUM(payer_coverage) / SUM(total_cost) * 100
            ELSE 0
        END, 1
    ) AS payer_coverage_pct,
    ROUND(SUM(out_of_pocket_cost), 2) AS total_out_of_pocket
FROM medications
GROUP BY medication_code
ORDER BY total_medication_cost DESC
