# Feature 7: Platinum Layer Views

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Create demonstration views for end-to-end verification and use case organization.

## Scope

- Create simple use case views (patient summary, encounter counts)
- Implement basic analytics queries
- Set up view documentation

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Patient Summary | `dbt/models/4_platinum_info_mart/patient_summary.sql` | Patient overview view |
| Encounter Metrics | `dbt/models/4_platinum_info_mart/encounter_metrics.sql` | Encounter statistics |
| Schema config | `dbt/models/4_platinum_info_mart/_schema.yml` | Documentation |

## Acceptance Criteria

- [ ] Views execute successfully
- [ ] Basic analytics queries return results
- [ ] End-to-end data flow verified
- [ ] Views are queryable by BI tools

## Dependencies

- Feature 6: Gold Layer Demonstration

---

## User Stories

### 0x01_us: Create Patient Summary View

**As a** data analyst  
**I want** a patient summary view  
**So that** I can quickly access key patient metrics  

**Acceptance Criteria:**
- View aggregates patient data from gold layer
- Includes patient count, demographics summary
- Queryable without errors
- Returns meaningful data

**Success Metrics:**
```bash
# Success: View runs and returns data
cd dbt && dbt run --select patient_summary
# Exit code 0
# Query: SELECT * FROM platinum_info_mart.patient_summary
# Returns rows with patient metrics
```

**Failure Metrics:**
- View fails to compile
- Empty results
- Runtime errors

---

### 0x02_us: Create Encounter Metrics View

**As a** data analyst  
**I want** an encounter metrics view  
**So that** I can analyze healthcare utilization  

**Acceptance Criteria:**
- View aggregates encounter data
- Includes counts by type, time period
- Queryable without errors
- Returns meaningful data

**Success Metrics:**
```bash
# Success: View runs and returns data
cd dbt && dbt run --select encounter_metrics
# Exit code 0
# Query: SELECT * FROM platinum_info_mart.encounter_metrics
# Returns rows with encounter counts
```

**Failure Metrics:**
- View fails to compile
- Empty results
- Runtime errors

---

### 0x03_us: Document Platinum Views

**As a** data analyst  
**I want** documentation for platinum layer views  
**So that** I understand what data is available  

**Acceptance Criteria:**
- `_schema.yml` exists with view definitions
- Each view has description
- Key columns documented
- dbt docs shows views correctly

**Success Metrics:**
```bash
# Success: Docs generate successfully
cd dbt && dbt docs generate
# Exit code 0
# Views appear in documentation
```

**Failure Metrics:**
- Schema file missing
- Documentation incomplete
- dbt docs fails

---

## Notes

- Platinum views are always materialized as views (virtual layer)
- Views should be organized by use case in future phases
- These demonstration views prove end-to-end data flow
