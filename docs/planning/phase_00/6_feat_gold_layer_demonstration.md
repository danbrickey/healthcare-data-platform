# Feature 6: Gold Layer Demonstration

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Create minimal business vault and dimensional models to demonstrate gold layer patterns.

## Scope

- Create basic PIT table for patient history
- Implement simple dimensional models (dim_patient, fct_encounter)
- Set up business logic for basic transformations

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Patient PIT | `dbt/models/3_gold_business_vault/business_vault/pit_patient.sql` | Point-in-time table |
| Patient Dimension | `dbt/models/3_gold_business_vault/dimensional/dim_patient.sql` | Patient dimension |
| Encounter Fact | `dbt/models/3_gold_business_vault/dimensional/fct_encounter.sql` | Encounter fact table |

## Acceptance Criteria

- [ ] Gold layer models compile successfully
- [ ] Basic business logic applied
- [ ] Dimensional models query correctly
- [ ] PIT table enables point-in-time queries

## Dependencies

- Feature 5: Silver Layer Foundation

---

## User Stories

### 0x01_us: Create Patient Point-in-Time Table

**As a** data engineer  
**I want** a PIT table for patient data  
**So that** I can efficiently query patient state at any point in time  

**Acceptance Criteria:**
- Model joins hub with related satellites
- As-of-date column present for temporal queries
- Satellite hash keys and load dates captured
- Model compiles and runs

**Success Metrics:**
```bash
# Success: PIT model runs
cd dbt && dbt run --select pit_patient
# Exit code 0
# Query: Can retrieve patient state for specific date
```

**Failure Metrics:**
- Missing satellite references
- Temporal logic incorrect
- Model fails to compile

---

### 0x02_us: Create Patient Dimension

**As a** data engineer  
**I want** a patient dimension table  
**So that** downstream analytics have denormalized patient data  

**Acceptance Criteria:**
- Model flattens hub and satellite data
- Business-friendly column names
- Current state represented (latest satellite version)
- Key patient attributes included
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Dimension model runs
cd dbt && dbt run --select dim_patient
# Exit code 0
# Query: SELECT patient_id, full_name, birth_date, gender FROM gold_dimensional.dim_patient LIMIT 1
# Returns valid data
```

**Failure Metrics:**
- Missing key attributes
- Incorrect latest record logic
- Model fails to compile

---

### 0x03_us: Create Encounter Fact Table

**As a** data engineer  
**I want** an encounter fact table  
**So that** downstream analytics can analyze encounter metrics  

**Acceptance Criteria:**
- Model contains encounter events with measures
- Foreign keys to patient dimension
- Date keys for temporal analysis
- Basic measures (cost, duration) if available
- Model compiles and runs

**Success Metrics:**
```bash
# Success: Fact model runs
cd dbt && dbt run --select fct_encounter
# Exit code 0
# Query: SELECT encounter_id, patient_id, encounter_date FROM gold_dimensional.fct_encounter LIMIT 1
# Returns valid data
```

**Failure Metrics:**
- Missing foreign keys
- Invalid measures
- Model fails to compile

---

### 0x04_us: Add Gold Layer Tests

**As a** data engineer  
**I want** tests for gold layer models  
**So that** data quality is verified in business models  

**Acceptance Criteria:**
- `_schema.yml` exists with model definitions
- Unique tests on primary keys
- Not-null tests on required columns
- Relationship tests between fact and dimensions
- Tests pass

**Success Metrics:**
```bash
# Success: Tests pass
cd dbt && dbt test --select 3_gold_business_vault
# Exit code 0, all tests pass
```

**Failure Metrics:**
- Tests fail
- Missing test coverage
- Schema file missing

---

## Notes

- Dimensional models should be tables (not views) for query performance
- PIT tables can be incremental or table depending on volume
- Follow Kimball dimensional modeling principles
