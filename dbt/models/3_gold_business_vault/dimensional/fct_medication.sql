WITH medications AS (
    SELECT
        hk_patient_encounter_medication AS medication_key,
        hk_patient AS patient_key,
        hk_encounter AS encounter_key,
        code AS medication_code,
        description AS medication_description,
        medication_start,
        medication_stop,
        base_cost,
        payer_coverage,
        total_cost,
        total_cost - payer_coverage AS out_of_pocket_cost,
        dispenses,
        reason_code,
        reason_description,
        record_source,
        ROW_NUMBER() OVER (
            PARTITION BY hk_patient_encounter_medication
            ORDER BY medication_stop DESC NULLS LAST
        ) AS rn
    FROM {{ ref('stg_synthea__medications_hashed') }}
)

SELECT
    medication_key,
    patient_key,
    encounter_key,
    medication_code,
    medication_description,
    medication_start,
    medication_stop,
    base_cost,
    payer_coverage,
    total_cost,
    out_of_pocket_cost,
    dispenses,
    reason_code,
    reason_description,
    record_source
FROM medications
WHERE rn = 1
