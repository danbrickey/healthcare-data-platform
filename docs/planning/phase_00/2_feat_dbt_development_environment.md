# Feature 2: dbt Development Environment

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Complete

---

## Objective

Configure dbt with AutomateDV and project structure for medallion architecture.

## Scope

- Install dbt-duckdb and required packages
- Configure dbt profiles for local development
- Set up AutomateDV package integration
- Verify dbt commands (debug, deps, compile)
- Configure dbt project structure with medallion layers

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| dbt profile | `~/.dbt/profiles.yml` | Connection configuration |
| Package config | `dbt/packages.yml` | Package dependencies |
| Project config | `dbt/dbt_project.yml` | Project settings |
| Package lock | `dbt/package-lock.yml` | Locked versions |

## Acceptance Criteria

- [x] `dbt debug` succeeds
- [x] `dbt deps` installs all packages without errors
- [x] All medallion directories recognized by dbt
- [x] AutomateDV macros available

## Dependencies

- Feature 1: Database Environment Setup

---

## User Stories

### 0x01_us: Install dbt-duckdb Package

**As a** data engineer  
**I want** dbt-duckdb installed in my Python environment  
**So that** I can run dbt commands against DuckDB  

**Acceptance Criteria:**
- `dbt-duckdb` package installed
- `dbt --version` shows dbt-duckdb adapter
- Python environment is functional

**Success Metrics:**
```bash
# Success: dbt-duckdb appears in version output
dbt --version
# Output contains "dbt-duckdb"
```

**Failure Metrics:**
- Package not found error
- Import errors when running dbt
- Version mismatch with project requirements

---

### 0x02_us: Configure dbt Profile

**As a** data engineer  
**I want** a dbt profile configured for the healthcare platform  
**So that** dbt can connect to the correct database  

**Acceptance Criteria:**
- Profile exists in `~/.dbt/profiles.yml`
- Profile name matches `healthcare_platform`
- Database path points to `data/healthcare.duckdb`
- Target is set to `dev`

**Success Metrics:**
```bash
# Success: Profile validation passes
cd dbt && dbt debug --config-dir
# Output shows profile found and valid
```

**Failure Metrics:**
- Profile not found error
- Incorrect database path
- Missing required configuration keys

---

### 0x03_us: Install dbt Packages

**As a** data engineer  
**I want** all dbt packages installed (automate_dv, dbt_utils)  
**So that** I can use Data Vault macros and utilities  

**Acceptance Criteria:**
- `dbt deps` completes without errors
- `dbt_packages/` directory created
- automate_dv package present
- dbt_utils package present

**Success Metrics:**
```bash
# Success: deps installs successfully
cd dbt && dbt deps
# Exit code 0, no error messages
# dbt_packages/ directory exists with subdirectories
```

**Failure Metrics:**
- Network errors during download
- Package version conflicts
- Missing package directory after install

---

### 0x04_us: Verify Project Configuration

**As a** data engineer  
**I want** dbt project configuration to match medallion architecture  
**So that** models are organized correctly by layer  

**Acceptance Criteria:**
- `dbt_project.yml` has model configs for all layers
- Schema names match medallion naming convention
- Materialization settings appropriate per layer

**Success Metrics:**
```bash
# Success: dbt compile recognizes all model paths
cd dbt && dbt compile --select 1_bronze_data_lake
cd dbt && dbt compile --select 2_silver_raw_vault
cd dbt && dbt compile --select 3_gold_business_vault
cd dbt && dbt compile --select 4_platinum_info_mart
# All commands exit with code 0
```

**Failure Metrics:**
- Model path not recognized errors
- Schema configuration missing
- Compilation errors in project config

---

## Notes

- Profile should use relative path for database
- AutomateDV version should be pinned for stability
- IDE extensions (dbt Power User) recommended but not required
