{{- config(
    materialized='incremental',
    unique_key=['hk_patient', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__patients_hashed'
src_pk: 'hk_patient'
src_hashdiff: 'hd_patient_demographics'
src_payload:
  - 'first_name'
  - 'last_name'
  - 'birth_date'
  - 'death_date'
  - 'gender'
  - 'race'
  - 'ethnicity'
  - 'marital_status'
  - 'ssn'
src_eff: 'effective_from'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(
    src_pk=metadata_dict['src_pk'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
