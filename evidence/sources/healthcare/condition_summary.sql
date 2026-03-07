select
    condition_code,
    condition_description,
    condition_count,
    unique_patients,
    avg_duration_days,
    earliest_diagnosis,
    latest_diagnosis
from main_platinum_info_mart.condition_summary
