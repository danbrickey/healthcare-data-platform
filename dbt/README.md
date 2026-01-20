# Healthcare Data Platform - dbt Project

This dbt project implements a Data Vault 2.0 architecture for healthcare data transformation using DuckDB.

## Project Structure

```
dbt/
├── models/
│   ├── staging/          # Source data cleaning and standardization
│   ├── raw_vault/        # Data Vault 2.0 core structures
│   │   ├── hubs/         # Business keys
│   │   ├── links/        # Relationships between hubs
│   │   └── sats/         # Descriptive attributes
│   ├── business_vault/   # Derived business logic
│   └── marts/            # Reporting and analytics layer
├── macros/               # Reusable SQL functions
├── seeds/                # Static reference data
├── tests/                # Data quality tests
├── snapshots/            # Slowly changing dimensions
└── analyses/             # Ad-hoc queries
```

## Setup

1. Copy `profiles.yml.example` to `~/.dbt/profiles.yml`:
   ```bash
   cp profiles.yml.example ~/.dbt/profiles.yml
   ```

2. Install dbt packages:
   ```bash
   dbt deps
   ```

3. Verify configuration:
   ```bash
   dbt debug
   ```

## Data Vault 2.0 Naming Conventions

- **Staging models**: `stg_<source>__<entity>.sql`
- **Hubs**: `hub_<business_key>.sql`
- **Links**: `link_<relationship>.sql`
- **Satellites**: `sat_<hub>_<descriptor>.sql`

## Common Commands

- `dbt run` - Build all models
- `dbt test` - Run data quality tests
- `dbt docs generate` - Generate documentation
- `dbt docs serve` - Serve documentation locally

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Data Vault 2.0 Standards](https://danlinstedt.com/solutions-2/data-vault-basics/)
- [dbt-utils Package](https://github.com/dbt-labs/dbt-utils)
