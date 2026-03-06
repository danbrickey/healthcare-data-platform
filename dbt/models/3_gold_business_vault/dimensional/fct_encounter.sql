WITH encounters AS (
    SELECT
        hk_encounter AS encounter_key,
        hk_patient AS patient_key,
        encounter_id,
        CAST(encounter_start AS DATE) AS encounter_date,
        encounter_start,
        encounter_stop,
        encounter_class,
        code,
        description,
        reason_code,
        reason_description,
        base_encounter_cost,
        total_claim_cost,
        payer_coverage,
        total_claim_cost - payer_coverage AS out_of_pocket_cost,
        record_source
    FROM {{ ref('stg_synthea__encounters_hashed') }}
)

SELECT * FROM encounters
