# AutomateDV Pattern Reference

> Code patterns for Data Vault 2.0 implementation using AutomateDV macros.
> Use as context for AI code generation and developer reference.

---

## Conventions

### Naming Patterns

| Object | Pattern | Example |
|--------|---------|---------|
| Staging (hashed) | `stg_<source>__<entity>_hashed` | `stg_synthea__patients_hashed` |
| Hub | `h_<entity>` | `h_patient` |
| Link | `l_<entity1>_<entity2>` | `l_claim_patient` |
| Transactional Link | `t_link_<event>` | `t_link_claim_transaction` |
| Satellite | `s_<parent>_<context>` | `s_patient_demographics` |
| Effectivity Satellite | `s_<link>_eff` | `s_patient_payer_eff` |
| Multi-Active Satellite | `s_<parent>_<context>_ma` | `s_patient_address_ma` |
| Extended Tracking Sat | `xts_<entity>` | `xts_patient` |
| Point-in-Time | `pit_<entity>` | `pit_patient` |
| Bridge | `brg_<entity1>_<entity2>` | `brg_claim_diagnosis` |

### Column Naming

| Column Type | Pattern | Example |
|-------------|---------|---------|
| Hash key | `hk_<entity>` | `hk_patient` |
| Hashdiff | `hd_<satellite_name>` | `hd_patient_demographics` |
| Business key | `<entity>_id` | `patient_id` |
| Foreign key (link) | `hk_<referenced_entity>` | `hk_claim` |
| Load timestamp | `load_date` | `load_date` |
| Record source | `record_source` | `record_source` |
| Effective date | `effective_from` | `effective_from` |

### Materialization

| Object | Materialization | Unique Key |
|--------|-----------------|------------|
| Staging | `view` | — |
| Hub | `incremental` | `hk_<entity>` |
| Link | `incremental` | `hk_<link>` |
| Satellite | `incremental` | `[hk_<parent>, load_date]` |
| Multi-Active Sat | `incremental` | `[hk_<parent>, <cdk>, load_date]` |
| PIT | `incremental` | `[hk_<entity>, as_of_date]` |
| Bridge | `table` | — |

---

## Package Setup

**packages.yml**
```yaml
packages:
  - package: datavault-uk/automate_dv
    version: [">=0.10.0", "<0.11.0"]
```

---

## Staging (`stage`)

Prepares source data with hash keys and derived columns.

### Template

```sql
{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>'

derived_columns:
  record_source: '!<source_name>'
  load_date: 'current_timestamp()'
  effective_from: '<business_date_column>'

hashed_columns:
  hk_<entity>:
    - '<business_key>'
  hk_<entity1>_<entity2>:
    - '<business_key_1>'
    - '<business_key_2>'
  hd_<satellite_name>:
    is_hashdiff: true
    columns:
      - '<payload_col_1>'
      - '<payload_col_2>'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
```

### Example: stg_synthea__patients_hashed.sql

```sql
{%- set yaml_metadata -%}
source_model: 'stg_synthea__patients'

derived_columns:
  record_source: '!synthea'
  load_date: 'current_timestamp()'
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
      - 'gender'
      - 'race'
      - 'ethnicity'
  hd_patient_address:
    is_hashdiff: true
    columns:
      - 'street_address'
      - 'city'
      - 'state'
      - 'postal_code'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
```

### Example: stg_synthea__claims_hashed.sql

```sql
{%- set yaml_metadata -%}
source_model: 'stg_synthea__claims'

derived_columns:
  record_source: '!synthea'
  load_date: 'current_timestamp()'
  effective_from: 'service_date'

hashed_columns:
  hk_claim:
    - 'claim_id'
  hk_patient:
    - 'patient_id'
  hk_provider:
    - 'provider_id'
  hk_claim_patient:
    - 'claim_id'
    - 'patient_id'
  hk_claim_provider:
    - 'claim_id'
    - 'provider_id'
  hd_claim_header:
    is_hashdiff: true
    columns:
      - 'claim_status'
      - 'service_date'
      - 'total_charge_amount'
      - 'total_paid_amount'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    hashed_columns=metadata_dict['hashed_columns']
) }}
```

---

## Hub (`hub`)

Stores unique business keys.

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_<entity>'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<entity>'
src_nk: '<business_key>'
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
```

### Example: h_patient.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_patient'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__patients_hashed'
src_pk: 'hk_patient'
src_nk: 'patient_id'
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
```

### Example: h_provider.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_provider'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__providers_hashed'
src_pk: 'hk_provider'
src_nk: 'provider_id'
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
```

### Example: h_claim.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_claim'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__claims_hashed'
src_pk: 'hk_claim'
src_nk: 'claim_id'
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
```

### Example: h_encounter.sql

```sql
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
```

---

## Link (`link`)

Stores relationships between hubs.

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_<entity1>_<entity2>'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<entity1>_<entity2>'
src_fk:
  - 'hk_<entity1>'
  - 'hk_<entity2>'
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
```

### Example: l_claim_patient.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_claim_patient'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__claims_hashed'
src_pk: 'hk_claim_patient'
src_fk:
  - 'hk_claim'
  - 'hk_patient'
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
```

### Example: l_encounter_provider.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_encounter_provider'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounters_hashed'
src_pk: 'hk_encounter_provider'
src_fk:
  - 'hk_encounter'
  - 'hk_provider'
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
```

### Example: l_patient_payer.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_patient_payer'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__payer_transitions_hashed'
src_pk: 'hk_patient_payer'
src_fk:
  - 'hk_patient'
  - 'hk_payer'
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
```

### Example: l_encounter_provider_organization.sql (3-way link)

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_encounter_provider_org'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounters_hashed'
src_pk: 'hk_encounter_provider_org'
src_fk:
  - 'hk_encounter'
  - 'hk_provider'
  - 'hk_organization'
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
```

---

## Transactional Link (`t_link`)

Stores transaction events with payload (not deduplicated).

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_<transaction>'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<transaction>'
src_fk:
  - 'hk_<entity1>'
  - 'hk_<entity2>'
src_payload:
  - '<payload_col_1>'
  - '<payload_col_2>'
src_eff: '<effective_date_column>'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.t_link(
    src_pk=metadata_dict['src_pk'],
    src_fk=metadata_dict['src_fk'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: t_link_claim_transaction.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_claim_transaction'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__claims_transactions_hashed'
src_pk: 'hk_claim_transaction'
src_fk:
  - 'hk_claim'
  - 'hk_patient'
  - 'hk_provider'
src_payload:
  - 'line_number'
  - 'procedure_code'
  - 'modifier1'
  - 'modifier2'
  - 'place_of_service'
  - 'units'
  - 'charge_amount'
  - 'allowed_amount'
  - 'paid_amount'
  - 'patient_responsibility'
  - 'service_from_date'
  - 'service_to_date'
src_eff: 'service_from_date'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.t_link(
    src_pk=metadata_dict['src_pk'],
    src_fk=metadata_dict['src_fk'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: t_link_medication_dispense.sql

```sql
{{- config(
    materialized='incremental',
    unique_key='hk_medication_dispense'
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__medications_hashed'
src_pk: 'hk_medication_dispense'
src_fk:
  - 'hk_patient'
  - 'hk_encounter'
  - 'hk_medication'
  - 'hk_payer'
src_payload:
  - 'dispense_date'
  - 'quantity'
  - 'days_supply'
  - 'base_cost'
  - 'payer_coverage'
  - 'patient_paid'
src_eff: 'dispense_date'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.t_link(
    src_pk=metadata_dict['src_pk'],
    src_fk=metadata_dict['src_fk'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

---

## Satellite (`sat`)

Stores descriptive attributes with history tracking.

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_<parent>', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<parent>'
src_hashdiff: 'hd_<satellite_name>'
src_payload:
  - '<attribute_1>'
  - '<attribute_2>'
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
```

### Example: s_patient_demographics.sql

```sql
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
```

### Example: s_patient_address.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_patient', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__patients_hashed'
src_pk: 'hk_patient'
src_hashdiff: 'hd_patient_address'
src_payload:
  - 'street_address'
  - 'city'
  - 'state'
  - 'postal_code'
  - 'county'
  - 'latitude'
  - 'longitude'
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
```

### Example: s_claim_header.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_claim', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__claims_hashed'
src_pk: 'hk_claim'
src_hashdiff: 'hd_claim_header'
src_payload:
  - 'claim_status'
  - 'claim_type'
  - 'service_date'
  - 'admission_date'
  - 'discharge_date'
  - 'total_charge_amount'
  - 'total_allowed_amount'
  - 'total_paid_amount'
  - 'patient_responsibility'
  - 'primary_diagnosis_code'
  - 'drg_code'
src_eff: 'service_date'
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
```

### Example: s_provider_details.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_provider', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__providers_hashed'
src_pk: 'hk_provider'
src_hashdiff: 'hd_provider_details'
src_payload:
  - 'provider_name'
  - 'gender'
  - 'specialty'
  - 'npi'
  - 'address'
  - 'city'
  - 'state'
  - 'zip'
  - 'phone'
  - 'utilization'
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
```

### Example: s_encounter_details.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_encounter', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounters_hashed'
src_pk: 'hk_encounter'
src_hashdiff: 'hd_encounter_details'
src_payload:
  - 'encounter_class'
  - 'encounter_type'
  - 'start_date'
  - 'end_date'
  - 'reason_code'
  - 'reason_description'
  - 'base_encounter_cost'
  - 'total_claim_cost'
  - 'payer_coverage'
src_eff: 'start_date'
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
```

---

## Effectivity Satellite (`eff_sat`)

Tracks validity periods of relationships.

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_<link>', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<link>'
src_dfk: 'hk_<driving_entity>'
src_sfk: 'hk_<secondary_entity>'
src_start_date: '<start_date_column>'
src_end_date: '<end_date_column>'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict['src_pk'],
    src_dfk=metadata_dict['src_dfk'],
    src_sfk=metadata_dict['src_sfk'],
    src_start_date=metadata_dict['src_start_date'],
    src_end_date=metadata_dict['src_end_date'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: s_patient_payer_eff.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_patient_payer', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__payer_transitions_hashed'
src_pk: 'hk_patient_payer'
src_dfk: 'hk_patient'
src_sfk: 'hk_payer'
src_start_date: 'coverage_start_date'
src_end_date: 'coverage_end_date'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict['src_pk'],
    src_dfk=metadata_dict['src_dfk'],
    src_sfk=metadata_dict['src_sfk'],
    src_start_date=metadata_dict['src_start_date'],
    src_end_date=metadata_dict['src_end_date'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: s_provider_organization_eff.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_provider_organization', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_provider_affiliations_hashed'
src_pk: 'hk_provider_organization'
src_dfk: 'hk_provider'
src_sfk: 'hk_organization'
src_start_date: 'affiliation_start_date'
src_end_date: 'affiliation_end_date'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict['src_pk'],
    src_dfk=metadata_dict['src_dfk'],
    src_sfk=metadata_dict['src_sfk'],
    src_start_date=metadata_dict['src_start_date'],
    src_end_date=metadata_dict['src_end_date'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

---

## Multi-Active Satellite (`ma_sat`)

Stores multiple concurrent attribute sets (e.g., multiple addresses).

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_<parent>', '<child_key>', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_<source>__<entity>_hashed'
src_pk: 'hk_<parent>'
src_cdk:
  - '<child_dependent_key>'
src_hashdiff: 'hd_<satellite_name>'
src_payload:
  - '<attribute_1>'
  - '<attribute_2>'
src_eff: 'effective_from'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(
    src_pk=metadata_dict['src_pk'],
    src_cdk=metadata_dict['src_cdk'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: s_patient_address_ma.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_patient', 'address_type', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__patient_addresses_hashed'
src_pk: 'hk_patient'
src_cdk:
  - 'address_type'
src_hashdiff: 'hd_patient_address'
src_payload:
  - 'street_address'
  - 'city'
  - 'state'
  - 'postal_code'
  - 'county'
  - 'latitude'
  - 'longitude'
  - 'is_primary'
src_eff: 'effective_from'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(
    src_pk=metadata_dict['src_pk'],
    src_cdk=metadata_dict['src_cdk'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: s_encounter_diagnosis_ma.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_encounter', 'diagnosis_sequence', 'load_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'stg_synthea__encounter_diagnoses_hashed'
src_pk: 'hk_encounter'
src_cdk:
  - 'diagnosis_sequence'
src_hashdiff: 'hd_encounter_diagnosis'
src_payload:
  - 'diagnosis_code'
  - 'diagnosis_description'
  - 'diagnosis_type'
  - 'is_principal'
  - 'is_admitting'
  - 'poa_indicator'
src_eff: 'diagnosis_date'
src_ldts: 'load_date'
src_source: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(
    src_pk=metadata_dict['src_pk'],
    src_cdk=metadata_dict['src_cdk'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model']
) }}
```

---

## Point-in-Time Table (`pit`)

Efficient temporal queries joining hub with satellites.

### Template

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_<entity>', 'as_of_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'h_<entity>'
src_pk: 'hk_<entity>'
as_of_dates_table: 'as_of_date_spine'
satellites:
  s_<satellite_1>:
    pk:
      pk: 'hk_<entity>'
    ldts:
      ldts: 'load_date'
  s_<satellite_2>:
    pk:
      pk: 'hk_<entity>'
    ldts:
      ldts: 'load_date'
stage_tables_ldts:
  stg_<source>__<entity>_hashed: 'load_date'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.pit(
    src_pk=metadata_dict['src_pk'],
    as_of_dates_table=metadata_dict['as_of_dates_table'],
    satellites=metadata_dict['satellites'],
    stage_tables_ldts=metadata_dict['stage_tables_ldts'],
    source_model=metadata_dict['source_model']
) }}
```

### Example: pit_patient.sql

```sql
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
  s_patient_address:
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
```

### Example: pit_claim.sql

```sql
{{- config(
    materialized='incremental',
    unique_key=['hk_claim', 'as_of_date']
) -}}

{%- set yaml_metadata -%}
source_model: 'h_claim'
src_pk: 'hk_claim'
as_of_dates_table: 'as_of_date_spine'
satellites:
  s_claim_header:
    pk:
      pk: 'hk_claim'
    ldts:
      ldts: 'load_date'
  s_claim_status:
    pk:
      pk: 'hk_claim'
    ldts:
      ldts: 'load_date'
stage_tables_ldts:
  stg_synthea__claims_hashed: 'load_date'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.pit(
    src_pk=metadata_dict['src_pk'],
    as_of_dates_table=metadata_dict['as_of_dates_table'],
    satellites=metadata_dict['satellites'],
    stage_tables_ldts=metadata_dict['stage_tables_ldts'],
    source_model=metadata_dict['source_model']
) }}
```

### Supporting: as_of_date_spine.sql

```sql
{{- config(materialized='table') -}}

{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2020-01-01' as date)",
    end_date="cast(current_date as date)"
) }}
```

---

## Bridge Table (`bridge`)

Pre-joins link paths for query performance.

### Example: brg_claim_diagnosis.sql

```sql
{{- config(
    materialized='table'
) -}}

{%- set yaml_metadata -%}
source_model: 'l_claim_diagnosis'
src_pk: 'hk_claim_diagnosis_bridge'
src_ldts: 'load_date'
as_of_dates_table: 'as_of_date_spine'
bridge_walk:
  l_claim_diagnosis:
    bridge_link_pk: 'hk_claim_diagnosis'
    bridge_start_date: 'load_date'
    bridge_end_date: 'load_date'
    bridge_load_date: 'load_date'
    link_table: 'l_claim_diagnosis'
    link_pk: 'hk_claim_diagnosis'
    link_fk1: 'hk_claim'
    link_fk2: 'hk_diagnosis'
stage_tables_ldts:
  stg_synthea__claims_hashed: 'load_date'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.bridge(
    src_pk=metadata_dict['src_pk'],
    src_ldts=metadata_dict['src_ldts'],
    bridge_walk=metadata_dict['bridge_walk'],
    as_of_dates_table=metadata_dict['as_of_dates_table'],
    stage_tables_ldts=metadata_dict['stage_tables_ldts'],
    source_model=metadata_dict['source_model']
) }}
```

---

## Quick Reference

### Macro Parameters

| Macro | Required Parameters |
|-------|---------------------|
| `stage` | `source_model` |
| `hub` | `src_pk`, `src_nk`, `src_ldts`, `src_source`, `source_model` |
| `link` | `src_pk`, `src_fk`, `src_ldts`, `src_source`, `source_model` |
| `t_link` | `src_pk`, `src_fk`, `src_payload`, `src_ldts`, `src_source`, `source_model` |
| `sat` | `src_pk`, `src_hashdiff`, `src_payload`, `src_ldts`, `src_source`, `source_model` |
| `eff_sat` | `src_pk`, `src_dfk`, `src_sfk`, `src_start_date`, `src_end_date`, `src_ldts`, `src_source`, `source_model` |
| `ma_sat` | `src_pk`, `src_cdk`, `src_hashdiff`, `src_payload`, `src_ldts`, `src_source`, `source_model` |
| `pit` | `src_pk`, `as_of_dates_table`, `satellites`, `stage_tables_ldts`, `source_model` |
| `bridge` | `src_pk`, `src_ldts`, `bridge_walk`, `as_of_dates_table`, `stage_tables_ldts`, `source_model` |

### Healthcare Entity Map

| Entity | Hub | Key Satellites | Key Links |
|--------|-----|----------------|-----------|
| Patient | `h_patient` | `s_patient_demographics`, `s_patient_address` | `l_claim_patient`, `l_encounter_patient`, `l_patient_payer` |
| Provider | `h_provider` | `s_provider_details` | `l_encounter_provider`, `l_claim_provider` |
| Organization | `h_organization` | `s_organization_details` | `l_encounter_organization`, `l_provider_organization` |
| Encounter | `h_encounter` | `s_encounter_details` | `l_encounter_patient`, `l_encounter_provider` |
| Claim | `h_claim` | `s_claim_header` | `l_claim_patient`, `l_claim_provider`, `l_claim_diagnosis` |
| Payer | `h_payer` | `s_payer_details` | `l_patient_payer` |
| Diagnosis | `h_diagnosis` | `s_diagnosis_description` | `l_claim_diagnosis`, `l_encounter_diagnosis` |
| Procedure | `h_procedure` | `s_procedure_description` | `l_claim_procedure`, `l_encounter_procedure` |
| Medication | `h_medication` | `s_medication_details` | `t_link_medication_dispense` |

---

*Reference: [AutomateDV Documentation](https://automate-dv.readthedocs.io/en/latest/)*
