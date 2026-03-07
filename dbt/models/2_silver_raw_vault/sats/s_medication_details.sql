{{- config(
    materialized='incremental',
    unique_key=['hk_patient_encounter_medication', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__medications_hashed'
src_pk: 'hk_patient_encounter_medication'
src_hashdiff: 'hd_medication_details'
src_payload:
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
