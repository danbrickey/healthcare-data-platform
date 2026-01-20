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
**Data Vault 2.0**
- **Rationale:**
  - Highly scalable and flexible for evolving requirements
  - Separates business keys (Hubs), relationships (Links), and context (Satellites)
  - Excellent for healthcare data with complex relationships
  - Audit trail built-in with load dates
  - Supports incremental loading patterns
- **Usage:** Core data warehouse modeling methodology

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
| `hub_patient` | Patient ID | Unique patients in the system |
| `hub_provider` | Provider NPI | Healthcare providers (physicians, facilities) |
| `hub_organization` | Organization ID | Healthcare organizations/facilities |
| `hub_claim` | Claim ID | Insurance claims |
| `hub_encounter` | Encounter ID | Patient encounters (visits) |
| `hub_diagnosis` | Diagnosis Code | ICD-10 diagnosis codes |
| `hub_procedure` | Procedure Code | CPT/HCPCS procedure codes |
| `hub_medication` | Medication Code | RxNorm medication codes |
| `hub_payer` | Payer ID | Insurance payers/plans |

### 5.3 Core Links

| Link Name | Connected Hubs | Description |
|-----------|----------------|-------------|
| `link_claim_patient` | Claim, Patient | Associates claims with patients |
| `link_claim_provider` | Claim, Provider | Associates claims with rendering providers |
| `link_claim_diagnosis` | Claim, Diagnosis | Diagnoses on claims |
| `link_claim_procedure` | Claim, Procedure | Procedures performed on claims |
| `link_encounter_patient` | Encounter, Patient | Associates encounters with patients |
| `link_encounter_provider` | Encounter, Provider | Associates encounters with providers |
| `link_encounter_organization` | Encounter, Organization | Location of encounters |
| `link_patient_payer` | Patient, Payer | Patient insurance coverage |

### 5.4 Key Satellites

| Satellite Name | Parent Entity | Description |
|----------------|---------------|-------------|
| `sat_patient_demographics` | hub_patient | Patient demographics (name, DOB, gender, etc.) |
| `sat_patient_address` | hub_patient | Patient addresses (mutable) |
| `sat_provider_details` | hub_provider | Provider specialty, license info |
| `sat_claim_header` | hub_claim | Claim totals, dates, status |
| `sat_claim_line` | hub_claim | Individual claim line items |
| `sat_encounter_details` | hub_encounter | Encounter type, dates, costs |
| `sat_diagnosis_description` | hub_diagnosis | Diagnosis descriptions |
| `sat_procedure_description` | hub_procedure | Procedure descriptions |
| `sat_medication_details` | hub_medication | Medication names, dosages |

### 5.5 Data Vault Conventions

- **Hash Keys:** All Hub and Link surrogate keys use hashing of business keys
  - Recommended: Use `dbt_utils.generate_surrogate_key()` macro (SHA256 for dbt-utils v1.x+)
  - Alternative: Use `dbt_utils.surrogate_key()` macro for MD5 hashing (legacy, v0.x)
  - Choose one consistently across the project based on dbt-utils version
- **Load Timestamps:** All entities include `load_date` and `record_source` columns
- **Satellites:** Track historical changes with `load_date` as part of the key
- **Reference Tables:** Stored as Satellites for code descriptions

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
   - Calculated fields and derived data
   - Business rules application
   - PITs (Point in Time) tables
   - Bridges for many-to-many relationships

4. **Info Mart (`models/info_mart/`):**
   - Dimensional models (facts and dimensions)
   - Denormalized for query performance
   - Business-friendly column names
   - Aggregated metrics

## 7. Naming Conventions

### 7.1 dbt Models

**Data Lake Models:**
- Pattern: `stg_<source>__<entity>`
- Examples: 
  - `stg_synthea__patients`
  - `stg_synthea__claims`
  - `stg_synthea__encounters`

**Hubs:**
- Pattern: `hub_<entity>`
- Examples: 
  - `hub_patient`
  - `hub_provider`
  - `hub_claim`

**Links:**
- Pattern: `link_<entity1>_<entity2>[_<entity3>]`
- Examples: 
  - `link_claim_patient`
  - `link_claim_diagnosis`
  - `link_encounter_provider_organization` (if 3+ entities)

**Satellites:**
- Pattern: `sat_<parent>_<context>`
- Examples: 
  - `sat_patient_demographics`
  - `sat_claim_header`
  - `sat_encounter_details`

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
   - Data Lake: `stg_<source>__<entity>`
   - Hubs: `hub_<entity>`
   - Links: `link_<entity1>_<entity2>`
   - Satellites: `sat_<parent>_<context>`

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
   - Use dbt-utils and automate-dv packages where applicable

### 9.2 Common Patterns

**Hub Template:**
```sql
{{ config(materialized='incremental', unique_key='hk_entity') }}

with source as (
    select * from {{ ref('stg_synthea__source') }}
),

hashed as (
    select
        {{ dbt_utils.generate_surrogate_key(['entity_id']) }} as hk_entity
        , entity_id
        , load_date
        , record_source
    from source
    {% if is_incremental() %}
    where load_date > (select max(load_date) from {{ this }})
    {% endif %}
)

select * from hashed
```
*Note: `dbt_utils.generate_surrogate_key` uses SHA256 by default (v1.x+). For MD5 hashing, use the legacy `dbt_utils.surrogate_key` macro or configure accordingly.*

**Link Template:**
```sql
{{ config(materialized='incremental', unique_key='hk_link') }}

with source as (
    select * from {{ ref('stg_synthea__source') }}
),

hashed as (
    select
        {{ dbt_utils.generate_surrogate_key(['entity1_id', 'entity2_id']) }} as hk_link
        , {{ dbt_utils.generate_surrogate_key(['entity1_id']) }} as hk_entity1
        , {{ dbt_utils.generate_surrogate_key(['entity2_id']) }} as hk_entity2
        , load_date
        , record_source
    from source
    {% if is_incremental() %}
    where load_date > (select max(load_date) from {{ this }})
    {% endif %}
)

select * from hashed
```
*Note: `dbt_utils.generate_surrogate_key` uses SHA256 by default (v1.x+). For MD5 hashing, use the legacy `dbt_utils.surrogate_key` macro or configure accordingly.*

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
