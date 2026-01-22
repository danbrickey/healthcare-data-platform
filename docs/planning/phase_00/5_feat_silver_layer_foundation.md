# Feature 5: Silver Layer Foundation

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Establish core Data Vault structures with minimal entities using AutomateDV.

## Scope

- Create Patient Hub and related satellites
- Create Encounter Hub and Patient-Encounter Link
- Implement basic hub-link-satellite patterns
- Set up AutomateDV macros for vault generation

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Patient Hub | `dbt/models/2_silver_raw_vault/hubs/h_patient.sql` | Patient business key |
| Patient Demographics Sat | `dbt/models/2_silver_raw_vault/sats/s_patient_demographics.sql` | Patient attributes |
| Encounter Hub | `dbt/models/2_silver_raw_vault/hubs/h_encounter.sql` | Encounter business key |
| Patient-Encounter Link | `dbt/models/2_silver_raw_vault/links/l_patient_encounter.sql` | Relationship |
| Staged sources | `dbt/models/2_silver_raw_vault/staging/stg_*_hashed.sql` | Hashed staging models |

## Acceptance Criteria

- [ ] Hubs, Links, and Satellites create successfully
- [ ] Hash keys generate correctly
- [ ] Historical tracking works
- [ ] Vault objects compile and run

## Dependencies

- Feature 4: Bronze Layer Implementation

---

## User Stories

### 0x01_us: Create Hashed Staging for Patients

**As a** data engineer  
**I want** a hashed staging model for patients  
**So that** vault objects have pre-computed hash keys  

**Acceptance Criteria:**
- Model uses AutomateDV `stage()` macro
- Hash key `hk_patient` generated from `patient_id`
- Hashdiff `hd_patient_demographics` generated
- `record_source` and `load_date` derived columns added
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Hashed staging model runs
cd dbt && dbt run --select stg_synthea__patients_hashed
# Exit code 0
# Query: SELECT hk_patient, hd_patient_demographics FROM silver_raw_vault.stg_synthea__patients_hashed LIMIT 1
# Returns valid hash values (32-char MD5)
```

**Failure Metrics:**
- AutomateDV macro errors
- Hash columns missing or null
- Model fails to compile

---

### 0x02_us: Create Patient Hub

**As a** data engineer  
**I want** a Patient Hub table  
**So that** patient business keys are stored uniquely  

**Acceptance Criteria:**
- Model uses AutomateDV `hub()` macro
- Columns: `hk_patient`, `patient_id`, `load_date`, `record_source`
- Unique constraint on `hk_patient`
- Model is incremental
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Hub model runs
cd dbt && dbt run --select h_patient
# Exit code 0
# Query: SELECT COUNT(DISTINCT hk_patient) = COUNT(*) FROM silver_raw_vault.h_patient
# Returns true (all hash keys unique)
```

**Failure Metrics:**
- Duplicate hash keys
- Missing required columns
- Model fails to compile

---

### 0x03_us: Create Patient Demographics Satellite

**As a** data engineer  
**I want** a Patient Demographics Satellite  
**So that** patient attributes are tracked with history  

**Acceptance Criteria:**
- Model uses AutomateDV `sat()` macro
- Columns include `hk_patient`, `hd_patient_demographics`, payload columns
- `load_date` and `record_source` present
- Model is incremental with hashdiff change detection
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Satellite model runs
cd dbt && dbt run --select s_patient_demographics
# Exit code 0
# Query returns rows with hash keys matching hub
```

**Failure Metrics:**
- Hashdiff not detecting changes
- Missing payload columns
- Model fails to compile

---

### 0x04_us: Create Encounter Hub

**As a** data engineer  
**I want** an Encounter Hub table  
**So that** encounter business keys are stored uniquely  

**Acceptance Criteria:**
- Model uses AutomateDV `hub()` macro
- Columns: `hk_encounter`, `encounter_id`, `load_date`, `record_source`
- Unique constraint on `hk_encounter`
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Hub model runs
cd dbt && dbt run --select h_encounter
# Exit code 0
# All hash keys unique
```

**Failure Metrics:**
- Duplicate hash keys
- Model fails to compile

---

### 0x05_us: Create Patient-Encounter Link

**As a** data engineer  
**I want** a Link between Patient and Encounter  
**So that** the relationship is captured in the vault  

**Acceptance Criteria:**
- Model uses AutomateDV `link()` macro
- Columns: `hk_patient_encounter`, `hk_patient`, `hk_encounter`, `load_date`, `record_source`
- Link hash key derived from both foreign keys
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Link model runs
cd dbt && dbt run --select l_patient_encounter
# Exit code 0
# Query: Foreign keys exist in respective hubs
```

**Failure Metrics:**
- Link hash key incorrect
- Orphaned foreign keys
- Model fails to compile

---

## Notes

- Reference `docs/context/pattern_automate_dv.md` for AutomateDV patterns
- Use YAML metadata approach for all vault objects
- Incremental materialization required for production-like behavior
