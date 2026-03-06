{{- config(
    materialized='incremental',
    unique_key='hk_encounter'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounters_hashed'
src_pk: 'hk_encounter'
src_nk: 'encounter_id'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(
    src_pk=metadata_dict['src_pk'],
    src_nk=metadata_dict['src_nk'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
