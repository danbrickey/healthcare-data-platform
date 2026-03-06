select
    patient_id,
    full_name,
    gender,
    race,
    ethnicity,
    birth_date,
    death_date,
    is_deceased,
    marital_status,
    total_encounters,
    distinct_encounter_types,
    first_encounter_date,
    last_encounter_date,
    total_claim_cost,
    total_payer_coverage,
    total_out_of_pocket_cost
from main_platinum_info_mart.patient_summary
