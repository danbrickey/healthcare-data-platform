-- ============================================================
-- Healthcare Data Platform — End-to-End Pipeline Verification
-- ============================================================
-- Run after `dbt build` to verify data flows through all layers.
-- Execute with: duckdb healthcare.duckdb < scripts/verify_pipeline.sql

-- 1. Row counts across all medallion layers
SELECT '=== ROW COUNTS BY LAYER ===' AS section;

SELECT 'bronze' AS layer, 'stg_synthea__patients' AS model, COUNT(*) AS row_count
    FROM main_bronze_data_lake.stg_synthea__patients
UNION ALL
SELECT 'bronze', 'stg_synthea__encounters', COUNT(*)
    FROM main_bronze_data_lake.stg_synthea__encounters
UNION ALL
SELECT 'silver', 'h_patient', COUNT(*)
    FROM main_silver_raw_vault.h_patient
UNION ALL
SELECT 'silver', 'h_encounter', COUNT(*)
    FROM main_silver_raw_vault.h_encounter
UNION ALL
SELECT 'silver', 's_patient_demographics', COUNT(*)
    FROM main_silver_raw_vault.s_patient_demographics
UNION ALL
SELECT 'silver', 'l_patient_encounter', COUNT(*)
    FROM main_silver_raw_vault.l_patient_encounter
UNION ALL
SELECT 'gold', 'pit_patient', COUNT(*)
    FROM main_gold_business_vault.pit_patient
UNION ALL
SELECT 'gold', 'dim_patient', COUNT(*)
    FROM main_gold_dimensional.dim_patient
UNION ALL
SELECT 'gold', 'fct_encounter', COUNT(*)
    FROM main_gold_dimensional.fct_encounter
UNION ALL
SELECT 'platinum', 'patient_summary', COUNT(*)
    FROM main_platinum_info_mart.patient_summary
UNION ALL
SELECT 'platinum', 'encounter_metrics', COUNT(*)
    FROM main_platinum_info_mart.encounter_metrics
ORDER BY layer, model;

-- 2. Sample patient summary (platinum layer)
SELECT '=== SAMPLE PATIENT SUMMARY (TOP 5) ===' AS section;

SELECT patient_id, full_name, gender, total_encounters, total_claim_cost
FROM main_platinum_info_mart.patient_summary
ORDER BY total_claim_cost DESC
LIMIT 5;

-- 3. Encounter metrics by class (platinum layer)
SELECT '=== ENCOUNTER METRICS BY CLASS ===' AS section;

SELECT encounter_class, encounter_count, unique_patients, avg_claim_cost
FROM main_platinum_info_mart.encounter_metrics
ORDER BY encounter_count DESC;

-- 4. Data lineage verification — trace one patient through all layers
SELECT '=== LINEAGE TRACE (FIRST PATIENT) ===' AS section;

WITH sample_patient AS (
    SELECT patient_id FROM main_bronze_data_lake.stg_synthea__patients LIMIT 1
)
SELECT 'bronze' AS layer, p.patient_id, NULL AS hash_key
    FROM main_bronze_data_lake.stg_synthea__patients p
    JOIN sample_patient sp ON p.patient_id = sp.patient_id
UNION ALL
SELECT 'silver_hub', h.patient_id, h.hk_patient
    FROM main_silver_raw_vault.h_patient h
    JOIN sample_patient sp ON h.patient_id = sp.patient_id
UNION ALL
SELECT 'gold_dim', d.patient_id, d.patient_key
    FROM main_gold_dimensional.dim_patient d
    JOIN sample_patient sp ON d.patient_id = sp.patient_id
UNION ALL
SELECT 'platinum', ps.patient_id, NULL
    FROM main_platinum_info_mart.patient_summary ps
    JOIN sample_patient sp ON ps.patient_id = sp.patient_id;
