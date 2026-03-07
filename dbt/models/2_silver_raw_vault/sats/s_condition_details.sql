{{- config(
    materialized='incremental',
    unique_key=['hk_patient_encounter_condition', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__conditions_hashed'
src_pk: 'hk_patient_encounter_condition'
src_hashdiff: 'hd_condition_details'
src_payload:
  - 'condition_start'
  - 'condition_stop'
  - 'code'
  - 'description'
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
