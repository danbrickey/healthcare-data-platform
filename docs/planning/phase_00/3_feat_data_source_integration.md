# Feature 3: Data Source Integration

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Set up Synthea synthetic data generation and dbt source definitions.

## Scope

- Create Synthea data generation scripts (Windows/Unix)
- Generate sample patient dataset (1,000-5,000 patients)
- Configure dbt sources for Synthea CSV files
- Set up source freshness monitoring
- Create data validation checks

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Windows script | `scripts/generate_synthea_data.ps1` | PowerShell data generation |
| Unix script | `scripts/generate_synthea_data.sh` | Bash data generation |
| CSV data files | `data/synthea/*.csv` | Generated synthetic data |
| Source config | `dbt/models/1_bronze_data_lake/_sources.yml` | dbt source definitions |

## Acceptance Criteria

- [ ] Synthea data generates successfully
- [ ] CSV files readable by DuckDB
- [ ] Source freshness tests pass
- [ ] Basic data quality checks implemented

## Dependencies

- Feature 2: dbt Development Environment

---

## User Stories

### 0x01_us: Create Data Generation Scripts

**As a** data engineer  
**I want** scripts to generate Synthea data on Windows and Unix  
**So that** I can create test data on any development machine  

**Acceptance Criteria:**
- PowerShell script exists at `scripts/generate_synthea_data.ps1`
- Bash script exists at `scripts/generate_synthea_data.sh`
- Scripts accept patient count parameter
- Scripts download Synthea if not present

**Success Metrics:**
```bash
# Success: Scripts exist and are readable
Test-Path scripts/generate_synthea_data.ps1  # True
Test-Path scripts/generate_synthea_data.sh   # True
```

**Failure Metrics:**
- Scripts don't exist
- Scripts fail to execute
- Scripts missing required functionality

---

### 0x02_us: Generate Sample Dataset

**As a** data engineer  
**I want** a small Synthea dataset generated  
**So that** I have test data for development  

**Acceptance Criteria:**
- CSV files exist in `data/synthea/`
- At least `patients.csv`, `encounters.csv`, `conditions.csv` present
- Patient count between 1,000-5,000
- Files contain valid data (headers, rows)

**Success Metrics:**
```bash
# Success: Key CSV files exist with data
Test-Path data/synthea/patients.csv      # True
Test-Path data/synthea/encounters.csv    # True
Test-Path data/synthea/conditions.csv    # True
# Each file has header + data rows
```

**Failure Metrics:**
- CSV files missing
- Files empty or only headers
- Synthea generation errors

---

### 0x03_us: Configure dbt Sources

**As a** data engineer  
**I want** dbt sources defined for all Synthea CSV files  
**So that** staging models can reference them consistently  

**Acceptance Criteria:**
- `_sources.yml` exists in bronze layer
- All Synthea tables defined as sources
- Source paths reference correct CSV locations
- Source descriptions documented

**Success Metrics:**
```bash
# Success: Sources compile without errors
cd dbt && dbt compile --select source:synthea
# Exit code 0
```

**Failure Metrics:**
- Source file missing or malformed
- Source references incorrect paths
- Compilation errors in source config

---

### 0x04_us: Verify Source Freshness

**As a** data engineer  
**I want** source freshness configured for key tables  
**So that** I can monitor data currency  

**Acceptance Criteria:**
- Freshness thresholds defined for `patients` source
- `dbt source freshness` command executes
- Freshness results show expected status

**Success Metrics:**
```bash
# Success: Source freshness runs without errors
cd dbt && dbt source freshness --select source:synthea.patients
# Exit code 0, freshness status returned
```

**Failure Metrics:**
- Freshness command fails
- Freshness configuration missing
- Source files not accessible

---

## Notes

- Synthea requires Java 11+ to run
- Data generation may take several minutes for larger datasets
- CSV files should be gitignored
