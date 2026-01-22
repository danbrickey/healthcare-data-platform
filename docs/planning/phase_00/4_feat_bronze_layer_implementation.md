# Feature 4: Bronze Layer Implementation

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Create staging models for raw data ingestion in the bronze layer.

## Scope

- Implement Synthea staging models (patients, encounters, conditions)
- Add data type casting and basic transformations
- Create source-to-staging lineage
- Implement basic data quality checks

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Patients staging | `dbt/models/1_bronze_data_lake/stg_synthea__patients.sql` | Patient staging model |
| Encounters staging | `dbt/models/1_bronze_data_lake/stg_synthea__encounters.sql` | Encounter staging model |
| Conditions staging | `dbt/models/1_bronze_data_lake/stg_synthea__conditions.sql` | Condition staging model |
| Schema config | `dbt/models/1_bronze_data_lake/_schema.yml` | Model documentation and tests |

## Acceptance Criteria

- [ ] All Synthea entities staged successfully
- [ ] Data types correctly cast
- [ ] Basic null/invalid value checks pass
- [ ] Staging models compile and run

## Dependencies

- Feature 3: Data Source Integration

---

## User Stories

### 0x01_us: Create Patients Staging Model

**As a** data engineer  
**I want** a staging model for patient data  
**So that** downstream models have clean, typed patient data  

**Acceptance Criteria:**
- Model file exists at expected path
- Model reads from `source('synthea', 'patients')`
- Columns renamed to snake_case convention
- Date columns cast to DATE type
- Model compiles and runs without errors

**Success Metrics:**
```bash
# Success: Model compiles and runs
cd dbt && dbt run --select stg_synthea__patients
# Exit code 0
# Query returns rows: SELECT COUNT(*) FROM bronze_data_lake.stg_synthea__patients > 0
```

**Failure Metrics:**
- Model fails to compile
- Runtime errors during execution
- Zero rows in output
- Type casting errors

---

### 0x02_us: Create Encounters Staging Model

**As a** data engineer  
**I want** a staging model for encounter data  
**So that** downstream models have clean encounter records  

**Acceptance Criteria:**
- Model file exists at expected path
- Model reads from `source('synthea', 'encounters')`
- Columns renamed to snake_case convention
- Timestamp columns properly typed
- Model compiles and runs without errors

**Success Metrics:**
```bash
# Success: Model compiles and runs
cd dbt && dbt run --select stg_synthea__encounters
# Exit code 0
# Query returns rows > 0
```

**Failure Metrics:**
- Model fails to compile
- Runtime errors during execution
- Zero rows in output

---

### 0x03_us: Create Conditions Staging Model

**As a** data engineer  
**I want** a staging model for condition/diagnosis data  
**So that** downstream models have clean clinical data  

**Acceptance Criteria:**
- Model file exists at expected path
- Model reads from `source('synthea', 'conditions')`
- Columns renamed to snake_case convention
- Model compiles and runs without errors

**Success Metrics:**
```bash
# Success: Model compiles and runs
cd dbt && dbt run --select stg_synthea__conditions
# Exit code 0
# Query returns rows > 0
```

**Failure Metrics:**
- Model fails to compile
- Runtime errors during execution
- Zero rows in output

---

### 0x04_us: Add Schema Documentation and Tests

**As a** data engineer  
**I want** schema documentation and basic tests for staging models  
**So that** models are documented and data quality is verified  

**Acceptance Criteria:**
- `_schema.yml` exists with model definitions
- Each model has description
- Key columns have descriptions
- Not-null tests on primary keys
- `dbt test` passes for staging models

**Success Metrics:**
```bash
# Success: Tests pass
cd dbt && dbt test --select 1_bronze_data_lake
# Exit code 0, all tests pass
```

**Failure Metrics:**
- Schema file missing or malformed
- Tests fail
- Missing model/column descriptions

---

## Notes

- Staging models should be views (no persistence needed)
- Column naming follows snake_case convention
- Source data types may need explicit casting
- Reference `docs/context/pattern_automate_dv.md` for patterns
