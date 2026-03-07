{{- config(
    materialized='incremental',
    unique_key='hk_patient_encounter_condition'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__conditions_hashed'
src_pk: 'hk_patient_encounter_condition'
src_fk:
  - 'hk_patient'
  - 'hk_encounter'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(
    src_pk=metadata_dict['src_pk'],
    src_fk=metadata_dict['src_fk'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
