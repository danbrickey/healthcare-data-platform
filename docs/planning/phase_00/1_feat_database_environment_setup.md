# Feature 1: Database Environment Setup

> **Phase**: Phase Zero - Infrastructure Foundation
> **Type**: Feature
> **Status**: Not Started

---

## Objective

Establish DuckDB database with medallion architecture schemas.

## Scope

- Create DuckDB database file structure
- Initialize medallion layer schemas (bronze, silver, gold, platinum)
- Verify database connectivity and permissions
- Set up database verification scripts

## Deliverables

| Deliverable | Path | Description |
|-------------|------|-------------|
| Database file | `data/healthcare.duckdb` | DuckDB database file |
| Schema setup script | `scripts/setup_database.sql` | SQL script to create schemas |
| Verification documentation | (inline) | Connection test results |

## Acceptance Criteria

- [ ] All medallion schemas exist in database
- [ ] Database file can be opened and queried
- [ ] Schema structure matches medallion design
- [ ] `dbt debug` connects successfully

## Dependencies

- None (first feature)

---

## User Stories

### 0x01_us: Create DuckDB Database File

**As a** data engineer  
**I want** a DuckDB database file created at the expected path  
**So that** dbt can connect and create objects  

**Acceptance Criteria:**
- Database file exists at `data/healthcare.duckdb`
- File is readable and writable
- File size > 0 bytes after initialization

**Success Metrics:**
```bash
# Success: File exists and is accessible
Test-Path data/healthcare.duckdb  # Returns True
```

**Failure Metrics:**
- File does not exist
- File permissions prevent read/write
- DuckDB cannot open the file

---

### 0x02_us: Initialize Medallion Schemas

**As a** data engineer  
**I want** all medallion layer schemas created in the database  
**So that** dbt models have proper schema targets  

**Acceptance Criteria:**
- Schema `bronze_data_lake` exists
- Schema `silver_raw_vault` exists
- Schema `gold_business_vault` exists
- Schema `gold_dimensional` exists
- Schema `platinum_info_mart` exists
- Schema `reference` exists

**Success Metrics:**
```sql
-- Success: All schemas returned
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('bronze_data_lake', 'silver_raw_vault', 
                      'gold_business_vault', 'gold_dimensional', 
                      'platinum_info_mart', 'reference');
-- Returns 6 rows
```

**Failure Metrics:**
- Any schema missing from query results
- Schema creation SQL fails to execute
- Schema names don't match expected values

---

### 0x03_us: Verify Database Connectivity

**As a** data engineer  
**I want** to verify dbt can connect to the database  
**So that** I can confirm the environment is ready for development  

**Acceptance Criteria:**
- `dbt debug` command succeeds
- Connection profile resolves correctly
- Database path is accessible

**Success Metrics:**
```bash
# Success: dbt debug exits with code 0
cd dbt && dbt debug
# Output contains "All checks passed!"
```

**Failure Metrics:**
- `dbt debug` exits with non-zero code
- Connection error messages in output
- Profile configuration errors

---

## Notes

- DuckDB is a file-based database; no server setup required
- Database file should be gitignored
- Schemas are created via SQL script, not dbt
