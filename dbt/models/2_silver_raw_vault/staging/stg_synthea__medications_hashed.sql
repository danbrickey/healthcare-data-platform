{%- set yaml_metadata -%}
source_model: 'stg_synthea__medications'

derived_columns:
  record_source: '!synthea'
  load_date: 'now()'
  effective_from: 'medication_start'

hashed_columns:
  hk_patient:
    - 'patient_id'
  hk_encounter:
    - 'encounter_id'
  hk_patient_encounter_medication:
    - 'patient_id'
    - 'encounter_id'
    - 'code'
    - 'medication_start_ts'
  hd_medication_details:
    is_hashdiff: true
    columns:
      - 'medication_start'
      - 'medication_stop'
      - 'code'
      - 'description'
      - 'base_cost'
      - 'payer_coverage'
      - 'dispenses'
      - 'total_cost'
      - 'reason_code'
      - 'reason_description'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
