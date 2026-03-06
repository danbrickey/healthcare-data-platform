{{- config(
    materialized='incremental',
    unique_key=['hk_patient', 'as_of_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'h_patient'
src_pk: 'hk_patient'
as_of_dates_table: 'as_of_date_spine'
satellites:
  s_patient_demographics:
    pk:
      pk: 'hk_patient'
    ldts:
      ldts: 'load_date'
stage_tables_ldts:
  stg_synthea__patients_hashed: 'load_date'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.pit(
    src_pk=metadata_dict['src_pk'],
    as_of_dates_table=metadata_dict['as_of_dates_table'],
    satellites=metadata_dict['satellites'],
    stage_tables_ldts=metadata_dict['stage_tables_ldts'],
    source_model=metadata_dict['source_model']
) }}
