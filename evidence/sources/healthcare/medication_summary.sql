select
    medication_code,
    medication_description,
    prescription_count,
    unique_patients,
    total_dispenses,
    avg_dispenses,
    total_medication_cost,
    avg_medication_cost,
    total_payer_coverage,
    payer_coverage_pct,
    total_out_of_pocket
from main_platinum_info_mart.medication_summary
