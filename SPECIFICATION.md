# Healthcare Data Platform - Project Specification

## 1. Project Overview

The Healthcare Data Platform is a portfolio project demonstrating modern data engineering practices for healthcare payer analytics. This platform ingests, transforms, and analyzes synthetic healthcare claims and patient data to provide actionable insights into healthcare costs, utilization patterns, and quality metrics.

**Project Type:** Portfolio/demonstration project  
**Domain:** Healthcare payer analytics  
**Primary Use Cases:**
- Claims cost analysis and trending
- Provider performance analytics
- Patient population health insights
- Risk adjustment calculations
- Quality measure reporting

**Documentation Sources:** Supporting documents live in `docs/` to keep this specification focused:
- `docs/project_metadata.md` - project metadata and ownership
- `docs/planning_notes.md` - planning notes and delivery priorities
- `docs/research_artifacts.md` - research links and open questions

## 2. Business Context

### Healthcare Payer Analytics Domain

Healthcare payers (insurance companies, Medicare/Medicaid programs) need to analyze vast amounts of claims and patient data to:
- **Cost Management:** Identify cost drivers, detect anomalies, and forecast spending
- **Network Management:** Evaluate provider performance and network adequacy
- **Quality Improvement:** Track clinical quality measures and patient outcomes
- **Risk Assessment:** Calculate risk scores for population health management
- **Regulatory Compliance:** Report to CMS and other regulatory bodies

### Portfolio Objectives

This project demonstrates proficiency in:
1. Modern data engineering tools and practices
2. Healthcare domain knowledge (claims data, FHIR, risk adjustment)
3. Scalable data architecture (Data Vault 2.0)
4. Analytics engineering with dbt
5. Cloud-based analytics infrastructure

## 3. Tech Stack

### Database Layer
**DuckDB (Local) / MotherDuck (Cloud)**
- **Rationale:** 
  - DuckDB provides a fast, embeddable OLAP database ideal for analytics workloads
  - MotherDuck extends DuckDB to the cloud with serverless architecture
  - Excellent integration with dbt
  - Columnar storage optimized for analytical queries
  - Cost-effective for portfolio projects (MotherDuck free tier available)
  - Easy local development with DuckDB CLI
- **Usage:** 
  - Local development: DuckDB files
  - Production/sharing: MotherDuck cloud instance

### Transformation Layer
**dbt Core**
- **Rationale:**
  - Industry-standard tool for analytics engineering
  - SQL-based transformations with Jinja templating
  - Built-in testing, documentation, and lineage
  - Version control friendly
  - Strong community and package ecosystem
- **Usage:** All data transformations, tests, and documentation

### Data Modeling Approach
**Data Vault 2.0 with automate_dv**
- **Rationale:**
  - Highly scalable and flexible for evolving requirements
  - Separates business keys (Hubs), relationships (Links), and context (Satellites)
  - Excellent for healthcare data with complex relationships
  - Audit trail built-in with load dates
  - Supports incremental loading patterns
- **Implementation:** [automate_dv](https://automate-dv.readthedocs.io/) dbt package
  - Provides standardized macros for Hub, Link, and Satellite generation
  - Ensures consistent Data Vault patterns across all models
  - Reduces boilerplate code and potential errors
  - Well-documented with active community support
- **Usage:** Core data warehouse modeling methodology; all Raw Vault objects built using automate_dv macros

### Business Intelligence Layer
**Evidence.dev**
- **Rationale:**
  - Modern, code-based BI tool
  - Markdown-based reports with SQL
  - Version control for all reports
  - Easy deployment and sharing
  - Works seamlessly with DuckDB/MotherDuck
- **Usage:** Dashboards and reports for analytics consumers

### Additional Tools
- **automate_dv:** dbt package for Data Vault 2.0 automation (Hubs, Links, Satellites)
- **Git/GitHub:** Version control and collaboration
- **Python:** Data generation and utility scripts
- **Docker:** Containerization for consistent environments (future)

## 4. Data Sources

### 4.1 Synthea Synthetic Data
**Primary Source:** [Synthea™ Patient Generator](https://synthetichealth.github.io/synthea/)

**Description:** Synthea generates realistic synthetic patient data including:
- Patient demographics and clinical records
- Medical encounters (office visits, ER, inpatient)
- Diagnoses (ICD-10 codes)
- Procedures (CPT codes)
- Medications and immunizations
- Claims and insurance data

**Format:** CSV files with FHIR-compatible structure

**Key Files:**
- `patients.csv` - Patient demographics
- `encounters.csv` - All patient encounters
- `conditions.csv` - Diagnoses
- `procedures.csv` - Procedures performed
- `medications.csv` - Medication prescriptions
- `claims.csv` - Insurance claims
- `claims_transactions.csv` - Claim line items
- `organizations.csv` - Healthcare organizations/facilities
- `providers.csv` - Healthcare providers
- `payers.csv` - Insurance payers

**Volume:** Configurable; recommended 10,000-100,000 patients for demo

### 4.2 CMS Public Datasets (Future)
**Potential Sources:**
- **Medicare Provider Utilization and Payment Data:** Physician/provider services
- **Hospital Compare Data:** Hospital quality measures
- **Medicare Spending Per Beneficiary:** Cost benchmarks
- **Part D Prescriber Data:** Drug prescription patterns

**Usage:** Supplement synthetic data with real-world benchmarks and reference data

## 5. Data Architecture (Data Vault 2.0)

### 5.1 Architecture Overview

The Data Vault model consists of three core entity types:

1. **Hubs:** Business keys and minimal metadata
2. **Links:** Relationships between business entities
3. **Satellites:** Descriptive attributes and historical context

### 5.2 Core Hubs

| Hub Name | Business Key | Description |
|----------|--------------|-------------|
| `h_patient` | Patient ID | Unique patients in the system |
| `h_provider` | Provider NPI | Healthcare providers (physicians, facilities) |
| `h_organization` | Organization ID | Healthcare organizations/facilities |
| `h_claim` | Claim ID | Insurance claims |
| `h_encounter` | Encounter ID | Patient encounters (visits) |
| `h_diagnosis` | Diagnosis Code | ICD-10 diagnosis codes |
| `h_procedure` | Procedure Code | CPT/HCPCS procedure codes |
| `h_medication` | Medication Code | RxNorm medication codes |
| `h_payer` | Payer ID | Insurance payers/plans |

### 5.3 Core Links

| Link Name | Connected Hubs | Description |
|-----------|----------------|-------------|
| `l_claim_patient` | Claim, Patient | Associates claims with patients |
| `l_claim_provider` | Claim, Provider | Associates claims with rendering providers |
| `l_claim_diagnosis` | Claim, Diagnosis | Diagnoses on claims |
| `l_claim_procedure` | Claim, Procedure | Procedures performed on claims |
| `l_encounter_patient` | Encounter, Patient | Associates encounters with patients |
| `l_encounter_provider` | Encounter, Provider | Associates encounters with providers |
| `l_encounter_organization` | Encounter, Organization | Location of encounters |
| `l_patient_payer` | Patient, Payer | Patient insurance coverage |

### 5.4 Key Satellites

| Satellite Name | Parent Entity | Description |
|----------------|---------------|-------------|
| `s_patient_demographics` | h_patient | Patient demographics (name, DOB, gender, etc.) |
| `s_patient_address` | h_patient | Patient addresses (mutable) |
| `s_provider_details` | h_provider | Provider specialty, license info |
| `s_claim_header` | h_claim | Claim totals, dates, status |
| `s_claim_line` | h_claim | Individual claim line items |
| `s_encounter_details` | h_encounter | Encounter type, dates, costs |
| `s_diagnosis_description` | h_diagnosis | Diagnosis descriptions |
| `s_procedure_description` | h_procedure | Procedure descriptions |
| `s_medication_details` | h_medication | Medication names, dosages |

### 5.5 Data Vault Conventions

- **Implementation Package:** All Raw Vault objects (Hubs, Links, Satellites) are built using [automate_dv](https://automate-dv.readthedocs.io/) macros
- **Hash Keys:** All Hub and Link surrogate keys use hashing of business keys
  - Use automate_dv's built-in hashing via `automate_dv.hash()` macro
  - Default hash algorithm: MD5 (configurable in automate_dv)
- **Standard Columns:** All entities include `load_date` and `record_source` columns (handled by automate_dv)
- **Satellites:** Track historical changes with `load_date` as part of the key; use `hashdiff` for change detection
- **Reference Tables:** Stored as Satellites for code descriptions
- **Staging Layer:** Use `automate_dv.stage()` macro to prepare source data with derived columns and hashed keys

### 5.6 Business Vault Entities

The Business Vault extends the Raw Vault with derived business logic and computed values:

| Entity Type | Prefix | Description |
|-------------|--------|-------------|
| Computed Satellite | `cs_` | Derived/calculated attributes from business rules |
| Bridge | `brg_` | Pre-joined snapshots across Links for query performance |
| PIT (Point-in-Time) | `pit_` | Temporal snapshots joining Hub with multiple Satellites |

**Computed Satellites (`cs_`):**
- Contain calculated fields derived from Raw Vault data
- Apply business rules, transformations, and enrichments
- Examples: `cs_patient_risk_score`, `cs_claim_cost_metrics`, `cs_provider_quality`

**Bridges (`brg_`):**
- Denormalize many-to-many relationships for easier querying
- Snapshot of Link relationships at a point in time
- Examples: `brg_claim_diagnosis`, `brg_patient_provider`

**PIT Tables (`pit_`):**
- Combine a Hub with its related Satellites at specific points in time
- Enable efficient temporal queries without complex joins
- Use automate_dv's `automate_dv.pit()` macro
- Examples: `pit_patient`, `pit_claim`, `pit_encounter`

## 6. Project Structure

### 6.1 Repository Layout

```
healthcare-data-platform/
├── SPECIFICATION.md          # This file
├── README.md                 # Project overview and setup instructions
├── .gitignore               
├── data/                     # Raw data files (not committed)
│   ├── raw/                  # Synthea CSV files
│   └── seeds/                # Reference data seeds
├── dbt_project/              # dbt project root
│   ├── dbt_project.yml       # dbt project configuration
│   ├── profiles.yml          # Connection profiles (local example)
│   ├── packages.yml          # dbt package dependencies
│   ├── models/               # dbt models
│   │   ├── data_lake/        # Data Lake layer (raw → cleaned)
│   │   │   ├── stg_synthea/  # Synthea source data lake models
│   │   │   └── schema.yml    # Source and model definitions
│   │   ├── raw_vault/        # Raw Data Vault entities
│   │   │   ├── hubs/         # Hub tables
│   │   │   ├── links/        # Link tables
│   │   │   ├── satellites/   # Satellite tables
│   │   │   └── schema.yml
│   │   ├── business_vault/   # Business rules and calculated fields
│   │   │   └── schema.yml
│   │   ├── info_mart/        # Business-focused dimensional models
│   │   │   ├── claims/       # Claims analytics info mart
│   │   │   ├── patients/     # Patient analytics info mart
│   │   │   ├── providers/    # Provider analytics info mart
│   │   │   └── schema.yml
│   │   └── schema.yml        # Top-level schema
│   ├── macros/               # Reusable dbt macros
│   │   ├── data_vault/       # Data Vault-specific macros
│   │   └── helpers/          # General helper macros
│   ├── tests/                # Custom dbt tests
│   ├── seeds/                # CSV reference data
│   └── snapshots/            # Slowly changing dimension snapshots
├── evidence_project/         # Evidence.dev project
│   ├── pages/                # Report pages
│   ├── sources/              # Data source connections
│   └── components/           # Reusable components
├── scripts/                  # Utility scripts
│   ├── generate_synthea.py   # Generate Synthea data
│   └── setup_duckdb.py       # Initialize DuckDB database
└── docs/                     # Additional documentation
    ├── data_dictionary.md    # Data element definitions
    └── setup_guide.md        # Environment setup guide
```

### 6.2 dbt Model Layers

1. **Data Lake (`models/data_lake/`):**
   - Light transformations on raw data
   - Rename columns to standard conventions
   - Cast data types
   - Basic filtering and deduplication
   - One data lake model per source table

2. **Raw Vault (`models/raw_vault/`):**
   - Hubs, Links, Satellites following Data Vault 2.0
   - Hash keys generated using MD5
   - Load timestamps and audit columns
   - Incremental loading strategy

3. **Business Vault (`models/business_vault/`):**
   - Computed Satellites (`cs_`): calculated fields and derived data with business rules
   - Bridges (`brg_`): denormalized Link snapshots for query performance
   - PIT tables (`pit_`): point-in-time Hub + Satellite joins for temporal queries

4. **Info Mart (`models/info_mart/`):**
   - Dimensional models (facts and dimensions)
   - Denormalized for query performance
   - Business-friendly column names
   - Aggregated metrics

## 7. Naming Conventions

### 7.0 General Naming Standard

**Lower Snake Case:** All file names, variable names, and object names throughout the project must use lower snake case (e.g., `patient_demographics`, `claim_header`, `total_charge_amount`). This applies to:
- SQL model files and YAML configuration files
- Database objects (tables, views, columns)
- Python variables, functions, and modules
- dbt macros and variables
- Any other named entities in the codebase

### 7.1 dbt Models

**Data Lake Models:**
- Pattern: `stg_<source>__<entity>`
- Examples: 
  - `stg_synthea__patients`
  - `stg_synthea__claims`
  - `stg_synthea__encounters`

**Hubs:**
- Pattern: `h_<entity>`
- Examples: 
  - `h_patient`
  - `h_provider`
  - `h_claim`

**Links:**
- Pattern: `l_<entity1>_<entity2>[_<entity3>]`
- Examples: 
  - `l_claim_patient`
  - `l_claim_diagnosis`
  - `l_encounter_provider_organization` (if 3+ entities)

**Satellites:**
- Pattern: `s_<parent>_<context>`
- Examples: 
  - `s_patient_demographics`
  - `s_claim_header`
  - `s_encounter_details`

**Computed Satellites (Business Vault):**
- Pattern: `cs_<parent>_<context>`
- Examples: 
  - `cs_patient_risk_score`
  - `cs_claim_cost_metrics`
  - `cs_provider_quality`

**Bridges (Business Vault):**
- Pattern: `brg_<entity1>_<entity2>`
- Examples: 
  - `brg_claim_diagnosis`
  - `brg_patient_provider`
  - `brg_encounter_procedure`

**PIT Tables (Business Vault):**
- Pattern: `pit_<entity>`
- Examples: 
  - `pit_patient`
  - `pit_claim`
  - `pit_encounter`

**Info Mart Models:**
- Pattern: `<domain>_<business_entity>`
- Examples: 
  - `claims_monthly_summary`
  - `patient_risk_scores`
  - `provider_performance_metrics`

### 7.2 Column Naming

**Standard Conventions:**
- Lowercase with underscores: `patient_id`, `total_charge_amount`
- Prefix surrogate keys: `hk_` for hash keys, `sk_` for sequence keys
- Suffix timestamps: `_date`, `_datetime`, `_timestamp`
- Business keys: `<entity>_id` (e.g., `patient_id`, `claim_id`)

**Data Vault Columns:**
- `hk_<entity>` - Hash key (surrogate key)
- `<entity>_id` - Business key
- `load_date` - Record load timestamp
- `record_source` - Source system identifier
- `hash_diff` - Satellite change detection hash

**Standardized Naming:**
- Dates: `service_start_date`, `claim_paid_date`
- Amounts: `total_charge_amount`, `allowed_amount`, `patient_paid_amount`
- Codes: `diagnosis_code`, `procedure_code`, `revenue_code`
- Indicators: `is_primary`, `is_active`, `has_complication`

### 7.3 File Naming

- All files lowercase with underscores
- SQL files: `<model_name>.sql`
- YAML files: `schema.yml` or `_<specific>_schema.yml`
- Python scripts: `<action>_<object>.py`

## 8. Development Workflow

### 8.1 Local Development Setup

1. **Install Prerequisites:**
   ```bash
   # Python 3.9+
   pip install dbt-duckdb
   
   # DuckDB CLI (optional)
   brew install duckdb  # macOS
   ```

2. **Clone Repository:**
   ```bash
   git clone https://github.com/danbrickey/healthcare-data-platform.git
   cd healthcare-data-platform
   ```

3. **Generate Synthea Data:**
   ```bash
   python scripts/generate_synthea.py --patients 10000
   ```

4. **Configure dbt Profile:**
   - Copy `dbt_project/profiles.yml.example` to `~/.dbt/profiles.yml`
   - Update database path for local DuckDB file

5. **Run dbt:**
   ```bash
   cd dbt_project
   dbt deps           # Install packages
   dbt seed           # Load reference data
   dbt run            # Build models
   dbt test           # Run tests
   dbt docs generate  # Generate documentation
   dbt docs serve     # View documentation
   ```

### 8.2 Development Process

1. **Create Feature Branch:**
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Develop Incrementally:**
   - Start with data lake models
   - Build out Data Vault layer
   - Create info mart models
   - Write tests alongside models

3. **Test Frequently:**
   ```bash
   dbt run --select model_name+    # Run model and downstream
   dbt test --select model_name    # Test specific model
   ```

4. **Document as You Go:**
   - Add descriptions in `schema.yml` files
   - Document column meanings and business logic
   - Use dbt docs for lineage visualization

5. **Commit and Push:**
   ```bash
   git add .
   git commit -m "Descriptive commit message"
   git push origin feature/descriptive-name
   ```

### 8.3 Code Quality Standards

**dbt Models:**
- Every model must have a corresponding entry in `schema.yml`
- All models must have a description
- Key business columns must have descriptions
- Add tests for primary keys, foreign keys, and critical business rules

**SQL Style:**
- Use lowercase SQL keywords
- Indent with 4 spaces
- Use CTEs for readability
- Put commas at the start of lines
- Meaningful CTE names

**Testing:**
- Unique and not_null tests on primary keys
- Relationship tests for foreign keys
- Accepted values tests for categorical fields
- Custom tests for business logic validation

### 8.4 Deployment (Future)

**MotherDuck Production:**
1. Create MotherDuck account and database
2. Update dbt profile for MotherDuck connection
3. Run dbt in production mode
4. Schedule incremental runs (e.g., daily)

**Evidence.dev:**
1. Connect Evidence to MotherDuck database
2. Develop reports in `evidence_project/`
3. Deploy to Evidence Cloud or self-host

## 9. AI Assistant Context

### 9.1 Key Conventions for AI Code Generation

When generating code for this project, AI assistants should:

1. **Always use absolute file paths** when working in the repository:
   - Repository root: The cloned repository directory
   - Example: `/Users/username/projects/healthcare-data-platform/` (macOS/Linux) or `C:\Users\username\projects\healthcare-data-platform\` (Windows)
   - Adjust based on your local environment or CI/CD setup

2. **Follow naming conventions strictly:**
   - All names use lower snake case
   - Data Lake: `stg_<source>__<entity>`
   - Hubs: `h_<entity>`
   - Links: `l_<entity1>_<entity2>`
   - Satellites: `s_<parent>_<context>`
   - Computed Satellites: `cs_<parent>_<context>`
   - Bridges: `brg_<entity1>_<entity2>`
   - PIT Tables: `pit_<entity>`

3. **Use Data Vault patterns:**
   - Generate hash keys using MD5 of business keys
   - Include `load_date` and `record_source` in all entities
   - Use incremental models for Satellites

4. **Reference existing models:**
   - Check `models/data_lake/` for source data structures
   - Build on existing Hubs and Links
   - Maintain consistent grain in Satellites

5. **Add tests automatically:**
   - Unique + not_null for all primary keys
   - Relationships for foreign keys
   - Document all tests in schema.yml

6. **SQL style:**
   - Lowercase keywords
   - Leading commas
   - Descriptive CTE names

7. **Use automate_dv macros for all Raw Vault objects:**
   - Hubs: `automate_dv.hub()`
   - Links: `automate_dv.link()`
   - Satellites: `automate_dv.sat()`
   - Staging: `automate_dv.stage()`

### 9.2 Common Patterns (automate_dv)

**Staged Source Template:**
```sql
{%- set yaml_metadata -%}
source_model: 'stg_synthea__source'
derived_columns:
    record_source: '!synthea'
    load_date: 'current_timestamp()'
hashed_columns:
    hk_entity: 'entity_id'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns']) }}
```

**Hub Template (h_):**
```sql
{%- set source_model = 'stg_synthea__source_hashed' -%}
{%- set src_pk = 'hk_entity' -%}
{%- set src_nk = 'entity_id' -%}
{%- set src_ldts = 'load_date' -%}
{%- set src_source = 'record_source' -%}

{{ automate_dv.hub(src_pk=src_pk,
                   src_nk=src_nk,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
```

**Link Template (l_):**
```sql
{%- set source_model = 'stg_synthea__source_hashed' -%}
{%- set src_pk = 'hk_entity1_entity2' -%}
{%- set src_fk = ['hk_entity1', 'hk_entity2'] -%}
{%- set src_ldts = 'load_date' -%}
{%- set src_source = 'record_source' -%}

{{ automate_dv.link(src_pk=src_pk,
                    src_fk=src_fk,
                    src_ldts=src_ldts,
                    src_source=src_source,
                    source_model=source_model) }}
```

**Satellite Template (s_):**
```sql
{%- set source_model = 'stg_synthea__source_hashed' -%}
{%- set src_pk = 'hk_entity' -%}
{%- set src_hashdiff = 'hd_entity_details' -%}
{%- set src_payload = ['column1', 'column2', 'column3'] -%}
{%- set src_ldts = 'load_date' -%}
{%- set src_source = 'record_source' -%}

{{ automate_dv.sat(src_pk=src_pk,
                   src_hashdiff=src_hashdiff,
                   src_payload=src_payload,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
```

### 9.3 Project-Specific Knowledge

**Healthcare Domain:**
- Claims data is the primary fact for analysis
- Patients can have multiple encounters and claims
- Providers can be individual practitioners or organizations
- ICD-10 codes represent diagnoses; CPT codes represent procedures
- Claims have headers (overall claim info) and lines (individual services)

**Synthea Data Specifics:**
- Patient IDs are UUIDs
- Encounter IDs link to claim IDs
- Organizations and Providers are separate entities
- All monetary amounts are in USD
- Dates are in YYYY-MM-DD format

**Performance Considerations:**
- Use incremental models for large tables (claims, encounters)
- Index hash keys for join performance
- Partition by date where applicable
- Aggregate at appropriate grain in info mart

## 10. Future Enhancements

- Integration with real CMS public datasets
- Advanced analytics: risk stratification, predictive modeling
- Real-time streaming data ingestion
- Multi-payer scenarios
- Docker containerization
- CI/CD pipeline with GitHub Actions
- Great Expectations for data quality
- dbt Cloud or Airflow for orchestration

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-19  
**Maintained By:** Dan Brickey
