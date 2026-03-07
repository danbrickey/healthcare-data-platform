{%- set yaml_metadata -%}
source_model: 'stg_synthea__conditions'

derived_columns:
  record_source: '!synthea'
  load_date: 'now()'
  effective_from: 'condition_start'

hashed_columns:
  hk_patient:
    - 'patient_id'
  hk_encounter:
    - 'encounter_id'
  hk_patient_encounter_condition:
    - 'patient_id'
    - 'encounter_id'
    - 'code'
  hd_condition_details:
    is_hashdiff: true
    columns:
      - 'condition_start'
      - 'condition_stop'
      - 'code'
      - 'description'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
