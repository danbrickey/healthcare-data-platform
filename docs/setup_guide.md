# Healthcare Data Platform - Setup Guide

Quick start guide for setting up the development environment.

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Python | 3.9+ | [python.org](https://www.python.org/downloads/) |
| dbt-duckdb | Latest | `pip install dbt-duckdb` |
| Java | 11+ | Required for Synthea data generation |
| Git | Latest | [git-scm.com](https://git-scm.com/downloads) |

### Java Installation

**Windows:**
- Download from [Adoptium](https://adoptium.net/)
- Install and add to PATH

**macOS:**
```bash
brew install openjdk@11
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install openjdk-11-jdk
```

## Setup Steps

### 1. Clone Repository

```bash
git clone <repository-url>
cd healthcare-data-platform
```

### 2. Install Python Dependencies

```bash
pip install dbt-duckdb
```

### 3. Configure dbt Profile

**Windows:**
```powershell
Copy-Item dbt\profiles.yml.example $env:USERPROFILE\.dbt\profiles.yml
```

**Unix/macOS:**
```bash
cp dbt/profiles.yml.example ~/.dbt/profiles.yml
```

Edit `profiles.yml` and update the database path if needed:
```yaml
path: '../data/healthcare.duckdb'  # Relative to dbt/ directory
```

### 4. Create DuckDB Database and Schemas

**Option A: Using DuckDB CLI**
```bash
duckdb data/healthcare.duckdb < scripts/setup_database.sql
```

**Option B: Using dbt**
```bash
cd dbt
dbt debug  # Creates database if it doesn't exist
# Then run setup_database.sql manually
```

### 5. Generate Synthea Data

**Windows:**
```powershell
.\scripts\generate_synthea_data.ps1 -PatientCount 1000
```

**Unix/macOS:**
```bash
./scripts/generate_synthea_data.sh 1000
```

This generates CSV files in `data/synthea/` directory.

### 6. Install dbt Packages

```bash
cd dbt
dbt deps
```

This installs:
- `automate_dv` - Data Vault 2.0 automation
- `dbt_utils` - Utility macros

### 7. Verify Setup

```bash
cd dbt

# Test connection
dbt debug

# Check sources
dbt source freshness

# List available models
dbt list
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SYNTHEA_DATA_PATH` | Path to Synthea CSV files | `data/synthea` |
| `DBT_DATABASE_PATH` | Path to DuckDB file | `data/healthcare.duckdb` |

## IDE Setup

### VS Code Extensions

Recommended extensions:
- **dbt Power User** - dbt syntax highlighting and autocomplete
- **SQL Tools** - SQL query execution
- **YAML** - YAML syntax support

### Cursor/Other IDEs

- Install dbt language server if available
- Configure SQL formatter
- Enable YAML syntax highlighting

## Verification Checklist

After setup, verify:

- [ ] `dbt debug` succeeds
- [ ] DuckDB file exists at `data/healthcare.duckdb`
- [ ] Synthea CSV files exist in `data/synthea/`
- [ ] `dbt deps` installed packages successfully
- [ ] All medallion schemas exist in DuckDB:
  - `bronze_data_lake`
  - `silver_raw_vault`
  - `gold_business_vault`
  - `gold_dimensional`
  - `platinum_views`
  - `reference`

## Troubleshooting

### dbt debug fails

**Issue:** Connection error to DuckDB

**Solution:**
- Verify `profiles.yml` path is correct
- Ensure DuckDB file directory exists
- Check file permissions

### Synthea generation fails

**Issue:** Java not found or wrong version

**Solution:**
- Verify Java installation: `java -version`
- Ensure Java 11+ is installed
- Check PATH includes Java bin directory

### Source freshness fails

**Issue:** CSV files not found

**Solution:**
- Verify `SYNTHEA_DATA_PATH` environment variable
- Check CSV files exist in specified directory
- Verify file permissions

## Next Steps

After Phase Zero setup:

1. Review `SPECIFICATION.md` for architecture overview
2. Check `docs/context/pattern_automate_dv.md` for code patterns
3. Start building Bronze layer models (`models/bronze/`)
4. Follow Milestone 1 deliverables in specification
