{%- set yaml_metadata -%}
source_model: 'stg_synthea__patients'

derived_columns:
  record_source: '!synthea'
  load_date: 'now()'
  effective_from: 'birth_date'

hashed_columns:
  hk_patient:
    - 'patient_id'
  hd_patient_demographics:
    is_hashdiff: true
    columns:
      - 'first_name'
      - 'last_name'
      - 'birth_date'
      - 'death_date'
      - 'gender'
      - 'race'
      - 'ethnicity'
      - 'marital_status'
      - 'ssn'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
