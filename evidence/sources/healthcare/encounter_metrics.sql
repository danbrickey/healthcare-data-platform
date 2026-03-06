select
    encounter_class,
    encounter_count,
    unique_patients,
    avg_claim_cost,
    avg_payer_coverage,
    avg_out_of_pocket_cost,
    total_claim_cost,
    total_payer_coverage,
    earliest_encounter,
    latest_encounter
from main_platinum_info_mart.encounter_metrics
