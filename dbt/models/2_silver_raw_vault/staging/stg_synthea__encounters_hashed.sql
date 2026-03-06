{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounters'

derived_columns:
  record_source: '!synthea'
  load_date: 'now()'
  effective_from: 'encounter_start'

hashed_columns:
  hk_encounter:
    - 'encounter_id'
  hk_patient:
    - 'patient_id'
  hk_patient_encounter:
    - 'patient_id'
    - 'encounter_id'
  hd_encounter_details:
    is_hashdiff: true
    columns:
      - 'encounter_class'
      - 'code'
      - 'description'
      - 'encounter_start'
      - 'encounter_stop'
      - 'reason_code'
      - 'reason_description'
      - 'base_encounter_cost'
      - 'total_claim_cost'
      - 'payer_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
