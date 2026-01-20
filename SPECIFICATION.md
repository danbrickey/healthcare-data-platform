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

**Description:** Synthea is an open-source synthetic patient population generator that produces realistic but entirely fictional electronic healthcare records. Patients are simulated from birth to death with disease progression modeled through state-machine modules driven by real-world prevalence and incidence data.

**Key Characteristics:**
- Demographics aligned with US Census data
- Longitudinal records with temporal consistency
- Standard medical terminologies (SNOMED-CT, RxNorm, LOINC, CVX, ICD-10, CPT)
- All identifiers are UUIDs for relational integrity
- Dates in ISO 8601 format with timezone awareness

**Format:** CSV files with FHIR-compatible structure (enabled via `exporter.csv.export = true`)

**CSV Files and Key Columns:**

| File | Description | Key Columns |
|------|-------------|-------------|
| `patients.csv` | Patient demographics | `id`, `birthdate`, `deathdate`, `ssn`, `first`, `last`, `gender`, `race`, `ethnicity`, `address`, `city`, `state`, `zip`, `county`, `lat`, `lon`, `healthcare_expenses`, `healthcare_coverage` |
| `encounters.csv` | Healthcare encounters | `id`, `start`, `stop`, `patient`, `organization`, `provider`, `payer`, `encounterclass`, `code`, `description`, `base_encounter_cost`, `total_claim_cost`, `payer_coverage`, `reasoncode`, `reasondescription` |
| `conditions.csv` | Diagnoses/conditions | `start`, `stop`, `patient`, `encounter`, `code` (SNOMED), `description` |
| `procedures.csv` | Procedures performed | `start`, `stop`, `patient`, `encounter`, `code` (SNOMED), `description`, `base_cost`, `reasoncode`, `reasondescription` |
| `medications.csv` | Medication orders | `start`, `stop`, `patient`, `payer`, `encounter`, `code` (RxNorm), `description`, `base_cost`, `payer_coverage`, `dispenses`, `totalcost`, `reasoncode`, `reasondescription` |
| `observations.csv` | Labs, vitals, assessments | `date`, `patient`, `encounter`, `category`, `code` (LOINC), `description`, `value`, `units`, `type` |
| `claims.csv` | Insurance claims | `id`, `patientid`, `providerid`, `primarypatientinsuranceid`, `secondarypatientinsuranceid`, `departmentid`, `patientdepartmentid`, `diagnosis1`-`diagnosis8`, `referringproviderid`, `appointmentid`, `currentillnessdate`, `servicedate`, `supervisingproviderid`, `status1`-`status2`, `statusp` |
| `claims_transactions.csv` | Claim line items | `id`, `claimid`, `chargeid`, `patientid`, `type`, `amount`, `method`, `fromdate`, `todate`, `placeofservice`, `procedurecode`, `modifier1`, `modifier2`, `diagnosisref1`-`diagnosisref4`, `units`, `departmentid`, `notes`, `unitamount`, `transferoutid`, `transfertype`, `payments`, `adjustments`, `transfers`, `outstanding`, `appointmentid`, `linenote`, `patientinsuranceid`, `feescheduleid`, `providerid`, `supervisingproviderid` |
| `organizations.csv` | Healthcare facilities | `id`, `name`, `address`, `city`, `state`, `zip`, `lat`, `lon`, `phone`, `revenue`, `utilization` |
| `providers.csv` | Healthcare providers | `id`, `organization`, `name`, `gender`, `speciality`, `address`, `city`, `state`, `zip`, `lat`, `lon`, `utilization` |
| `payers.csv` | Insurance payers | `id`, `name`, `address`, `city`, `state_headquartered`, `zip`, `phone`, `amount_covered`, `amount_uncovered`, `revenue`, `covered_encounters`, `uncovered_encounters`, `covered_medications`, `uncovered_medications`, `covered_procedures`, `uncovered_procedures`, `covered_immunizations`, `uncovered_immunizations`, `unique_customers`, `qols_avg`, `member_months` |
| `payer_transitions.csv` | Insurance coverage changes | `patient`, `memberid`, `start_year`, `end_year`, `payer`, `secondary_payer`, `ownership`, `ownername` |
| `allergies.csv` | Patient allergies | `start`, `stop`, `patient`, `encounter`, `code`, `system`, `description`, `type`, `category`, `reaction1`, `description1`, `severity1`, `reaction2`, `description2`, `severity2` |
| `immunizations.csv` | Immunization records | `date`, `patient`, `encounter`, `code` (CVX), `description`, `base_cost` |
| `careplans.csv` | Care plan records | `id`, `start`, `stop`, `patient`, `encounter`, `code`, `description`, `reasoncode`, `reasondescription` |
| `imaging_studies.csv` | Medical imaging metadata | `id`, `date`, `patient`, `encounter`, `series_uid`, `bodysite_code`, `bodysite_description`, `modality_code`, `modality_description`, `instance_uid`, `sop_code`, `sop_description`, `procedure_code` |
| `devices.csv` | Medical devices | `start`, `stop`, `patient`, `encounter`, `code`, `description`, `udi` |
| `supplies.csv` | Medical supplies | `date`, `patient`, `encounter`, `code`, `description`, `quantity` |

**Data Quality Considerations:**
- `stop` dates may be NULL for ongoing conditions/medications
- Optional fields may be unpopulated in default configuration
- Timestamps include timezone; standardize to UTC during staging
- Some modules produce sparse data; validate completeness per use case

**Volume:** Configurable; recommended 10,000-100,000 patients for demo

### 4.2 CMS Public Datasets (Future)
**Potential Sources:**
- **Medicare Provider Utilization and Payment Data:** Physician/provider services
- **Hospital Compare Data:** Hospital quality measures
- **Medicare Spending Per Beneficiary:** Cost benchmarks
- **Part D Prescriber Data:** Drug prescription patterns

**Usage:** Supplement synthetic data with real-world benchmarks and reference data

### 4.3 Data Ingestion Strategy

**Ingestion Method:** DuckDB's native CSV reading capabilities via dbt sources

**Process Flow:**
1. Generate Synthea data → `data/synthea/*.csv`
2. Define dbt sources pointing to CSV files using DuckDB's `read_csv_auto()` function
3. Data Lake models (`stg_synthea__*`) read from sources and apply light transformations
4. Raw Vault models consume staged data with hashing and audit columns

**Source Configuration (`dbt/models/data_lake/_sources.yml`):**
```yaml
version: 2

sources:
  - name: synthea
    description: Synthea synthetic healthcare data (CSV files)
    meta:
      external_location: "{{ env_var('SYNTHEA_DATA_PATH', 'data/synthea') }}"
    tables:
      - name: patients
        description: Patient demographics
        external:
          location: "{{ source.meta.external_location }}/patients.csv"
          options:
            header: true
      - name: encounters
        description: Healthcare encounters
      - name: conditions
        description: Patient conditions/diagnoses
      - name: procedures
        description: Medical procedures
      - name: medications
        description: Medication orders
      - name: observations
        description: Clinical observations (labs, vitals)
      - name: claims
        description: Insurance claims
      - name: claims_transactions
        description: Claim line items
      - name: organizations
        description: Healthcare organizations
      - name: providers
        description: Healthcare providers
      - name: payers
        description: Insurance payers
      - name: payer_transitions
        description: Patient insurance coverage changes
      - name: allergies
        description: Patient allergies
      - name: immunizations
        description: Immunization records
      - name: careplans
        description: Care plans
      - name: devices
        description: Medical devices
      - name: supplies
        description: Medical supplies
      - name: imaging_studies
        description: Imaging study metadata
```

**DuckDB Source Macro (`dbt/macros/read_csv_source.sql`):**
```sql
{% macro read_csv_source(source_name, table_name) %}
    read_csv_auto('{{ env_var("SYNTHEA_DATA_PATH", "data/synthea") }}/{{ table_name }}.csv', header=true)
{% endmacro %}
```

**Example Staging Model (`stg_synthea__patients.sql`):**
```sql
with source as (
    select * from {{ read_csv_source('synthea', 'patients') }}
),

renamed as (
    select
        id as patient_id
        , birthdate as birth_date
        , deathdate as death_date
        , ssn
        , first as first_name
        , last as last_name
        , gender
        , race
        , ethnicity
        , address as street_address
        , city
        , state
        , zip as postal_code
        , county
        , lat as latitude
        , lon as longitude
        , healthcare_expenses
        , healthcare_coverage
        , current_timestamp as load_date
        , 'synthea' as record_source
    from source
)

select * from renamed
```

### 4.4 Reference Data (Seeds)

Reference data loaded via dbt seeds for code lookups and enrichment:

| Seed File | Description | Source |
|-----------|-------------|--------|
| `icd10_codes.csv` | ICD-10-CM diagnosis code descriptions | CMS |
| `cpt_codes.csv` | CPT procedure code descriptions | AMA (subset) |
| `loinc_codes.csv` | LOINC observation code descriptions | Regenstrief |
| `rxnorm_codes.csv` | RxNorm medication code descriptions | NLM |
| `snomed_codes.csv` | SNOMED-CT code descriptions (subset) | SNOMED International |
| `place_of_service.csv` | Place of service codes | CMS |
| `encounter_class.csv` | Encounter class mappings | Internal |
| `payer_type.csv` | Payer type classifications | Internal |

**Seed Configuration (`dbt_project.yml`):**
```yaml
seeds:
  healthcare_data_platform:
    +schema: reference
    icd10_codes:
      +column_types:
        code: varchar
        description: varchar
    cpt_codes:
      +column_types:
        code: varchar
        description: varchar
```

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

### 5.6 Satellite History Tracking

**Full History Preservation:** All Raw Vault satellites maintain complete technical history using append-only inserts. Records are never updated or deleted.

**Required Metadata Columns:**
| Column | Description |
|--------|-------------|
| `hk_<entity>` | Hash key linking to parent Hub or Link |
| `hashdiff` | Hash of payload columns for change detection |
| `load_date` | Timestamp when record was loaded into the vault |
| `record_source` | Source system identifier (e.g., `synthea`) |
| `effective_from` | Business effective date (source timestamp when available) |

**History Tracking Rules:**
1. **Append-Only:** New satellite records are inserted; existing records are never modified
2. **Change Detection:** Use `hashdiff` to detect payload changes; only insert when hash differs
3. **Temporal Ordering:** `load_date` provides technical ordering; `effective_from` provides business ordering
4. **Late-Arriving Data:** Insert with actual `load_date`; use `effective_from` for correct business timeline
5. **Soft Deletes:** Track deletions via status satellites with `is_deleted` flag and `deleted_date`

**Satellite Types by History:**
| Type | History Tracking | Use Case |
|------|------------------|----------|
| Standard Satellite (`s_`) | Full history | All mutable attributes |
| Status Satellite (`s_<entity>_status`) | Full history | Active/inactive/deleted state |
| Multi-Active Satellite | Full history, multiple active | Multiple concurrent values (e.g., addresses, phone numbers) |

**Point-in-Time Queries:** Use PIT tables (`pit_`) to efficiently query the state of an entity at any historical point without complex satellite joins

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
├── CONTRIBUTING.md           # Contribution guidelines
├── .gitignore               
├── data/                     # Raw data files (not committed)
│   └── synthea/              # Synthea CSV files
├── dbt/                      # dbt project root
│   ├── dbt_project.yml       # dbt project configuration
│   ├── profiles.yml          # Connection profiles (local, gitignored)
│   ├── profiles.yml.example  # Example profile for setup
│   ├── packages.yml          # dbt package dependencies
│   ├── models/               # dbt models
│   │   ├── data_lake/        # Data Lake layer (raw → cleaned)
│   │   │   ├── stg_synthea/  # Synthea staging models
│   │   │   └── _sources.yml  # Source definitions
│   │   ├── raw_vault/        # Raw Data Vault entities
│   │   │   ├── hubs/         # Hub tables (h_*)
│   │   │   ├── links/        # Link tables (l_*)
│   │   │   ├── sats/         # Satellite tables (s_*)
│   │   │   └── _raw_vault.yml
│   │   ├── business_vault/   # Business rules and calculated fields
│   │   │   ├── computed_sats/ # Computed satellites (cs_*)
│   │   │   ├── bridges/      # Bridge tables (brg_*)
│   │   │   ├── pits/         # Point-in-time tables (pit_*)
│   │   │   └── _business_vault.yml
│   │   ├── info_mart/        # Business-focused dimensional models
│   │   │   ├── claims/       # Claims analytics mart
│   │   │   ├── patient/      # Patient analytics mart
│   │   │   ├── provider/     # Provider analytics mart
│   │   │   └── _info_mart.yml
│   │   └── _schema.yml       # Top-level schema
│   ├── macros/               # Reusable dbt macros
│   ├── tests/                # Custom dbt tests
│   ├── seeds/                # CSV reference data
│   ├── snapshots/            # Slowly changing dimension snapshots
│   └── analyses/             # Ad-hoc SQL analyses
├── evidence/                 # Evidence.dev project (future)
│   ├── pages/                # Report pages
│   ├── sources/              # Data source connections
│   └── components/           # Reusable components
├── scripts/                  # Utility scripts
│   ├── generate_synthea.py   # Generate Synthea data
│   └── load_to_duckdb.py     # Load CSVs into DuckDB
└── docs/                     # Additional documentation
    ├── planning_notes.md     # Planning and priorities
    ├── project_metadata.md   # Project metadata
    └── research_artifacts.md # Research links and notes
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

### 6.3 Info Mart Layer Details

The Info Mart provides business-ready dimensional models optimized for analytics and reporting.

**Claims Mart (`models/info_mart/claims/`):**

| Model | Type | Description |
|-------|------|-------------|
| `dim_claim` | Dimension | Claim header details with denormalized patient/provider info |
| `fct_claim_line` | Fact | Claim line-level transactions with costs and codes |
| `claims_daily_summary` | Aggregate | Daily claim volume and cost metrics |
| `claims_monthly_summary` | Aggregate | Monthly trends by payer, provider, diagnosis category |
| `claims_by_diagnosis` | Aggregate | Cost and utilization grouped by diagnosis |
| `claims_by_procedure` | Aggregate | Cost and utilization grouped by procedure |

**Patient Mart (`models/info_mart/patient/`):**

| Model | Type | Description |
|-------|------|-------------|
| `dim_patient` | Dimension | Current patient demographics and attributes |
| `dim_patient_history` | SCD Type 2 | Historical patient attribute changes |
| `patient_encounter_summary` | Aggregate | Encounter counts and costs per patient |
| `patient_condition_summary` | Aggregate | Active/historical conditions per patient |
| `patient_risk_profile` | Derived | Risk scores and health indicators |
| `patient_cohort` | Analytical | Patient segmentation for population health |

**Provider Mart (`models/info_mart/provider/`):**

| Model | Type | Description |
|-------|------|-------------|
| `dim_provider` | Dimension | Provider demographics and specialty |
| `dim_organization` | Dimension | Healthcare organization details |
| `provider_utilization` | Aggregate | Encounter and procedure volume by provider |
| `provider_cost_metrics` | Aggregate | Average costs and reimbursement by provider |
| `provider_quality_scores` | Derived | Quality metrics and performance indicators |
| `provider_network_analysis` | Analytical | Network adequacy and referral patterns |

**Shared Dimensions:**

| Model | Description |
|-------|-------------|
| `dim_date` | Date dimension with fiscal periods, holidays |
| `dim_diagnosis` | ICD-10 diagnosis codes with descriptions and categories |
| `dim_procedure` | CPT/HCPCS procedure codes with descriptions |
| `dim_payer` | Payer/insurance plan details |
| `dim_place_of_service` | Service location types |

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
   - Copy `dbt/profiles.yml.example` to `dbt/profiles.yml`
   - Update database path for local DuckDB file
   - Set environment variable: `export SYNTHEA_DATA_PATH=data/synthea`

5. **Run dbt:**
   ```bash
   cd dbt
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

### 8.4 Incremental Loading Strategy

**Incremental Models:** All Raw Vault and large Info Mart models use incremental materialization.

**Incremental Column:** `load_date` drives incremental logic for all vault objects.

**Model Materialization by Layer:**

| Layer | Materialization | Incremental Strategy |
|-------|-----------------|---------------------|
| Data Lake (`stg_*`) | View | N/A - always reads full source |
| Hubs (`h_*`) | Incremental | Append new business keys only |
| Links (`l_*`) | Incremental | Append new relationships only |
| Satellites (`s_*`) | Incremental | Append when `hashdiff` changes |
| Computed Sats (`cs_*`) | Incremental or Table | Depends on calculation complexity |
| Bridges (`brg_*`) | Table | Full refresh (snapshot) |
| PITs (`pit_*`) | Incremental | Append new as-of dates |
| Info Mart Dims | Table | Full refresh |
| Info Mart Facts | Incremental | Append new transactions |
| Info Mart Aggregates | Table | Full refresh |

**Late-Arriving Data Handling:**
1. Satellite inserts use actual `load_date` when data arrives
2. `effective_from` column captures business timestamp for correct ordering
3. PIT tables rebuilt daily to incorporate late arrivals
4. Bridge tables rebuilt to reflect current state

**Full Refresh Triggers:**
- Schema changes to source data
- Business key definition changes
- Hash algorithm changes
- Manual data corrections

### 8.5 Testing Strategy

**Standard dbt Tests:**

| Test Type | Applied To | Purpose |
|-----------|------------|---------|
| `unique` | All primary keys (`hk_*`, `id`) | Ensure no duplicates |
| `not_null` | All primary keys, required fields | Data completeness |
| `relationships` | Foreign keys between models | Referential integrity |
| `accepted_values` | Categorical fields (gender, status) | Valid domain values |

**Healthcare-Specific Tests:**

| Test | Description | Example |
|------|-------------|---------|
| `valid_date_range` | Dates within reasonable bounds | No future service dates, birth before death |
| `cost_hierarchy` | Cost fields follow business rules | `charge_amount >= allowed_amount >= paid_amount` |
| `code_format` | Medical codes match expected patterns | ICD-10: `^[A-Z][0-9]{2}\.?[0-9A-Z]{0,4}$` |
| `encounter_completeness` | Required fields present by encounter type | Inpatient has admit/discharge dates |
| `claim_balance` | Claim amounts reconcile | `paid + patient_resp + adjustment = allowed` |
| `patient_timeline` | Events occur in logical order | Encounter before claim, diagnosis during encounter |

**Custom Test Macros (`dbt/tests/`):**

```sql
-- tests/generic/valid_icd10_format.sql
{% test valid_icd10_format(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} is not null
  and not regexp_matches({{ column_name }}, '^[A-Z][0-9]{2}\.?[0-9A-Z]{0,4}$')
{% endtest %}
```

**Data Quality Checks:**
- Row count monitoring (alert on significant volume changes)
- Null rate monitoring for optional fields
- Distribution checks on key metrics (costs, ages, dates)
- Freshness checks on source data

### 8.6 Environment Configuration

**Target Environments:**

| Target | Database | Purpose | Schema Prefix |
|--------|----------|---------|---------------|
| `dev` | Local DuckDB file | Development | `dev_` |
| `ci` | Ephemeral DuckDB | CI/CD testing | `ci_` |
| `prod` | MotherDuck | Production | (none) |

**Profile Configuration (`dbt/profiles.yml`):**

```yaml
healthcare_data_platform:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "{{ env_var('DBT_DATABASE_PATH', 'target/healthcare.duckdb') }}"
      schema: dev
      threads: 4
    
    ci:
      type: duckdb
      path: ":memory:"
      schema: ci
      threads: 2
    
    prod:
      type: duckdb
      path: "md:healthcare_prod?motherduck_token={{ env_var('MOTHERDUCK_TOKEN') }}"
      schema: main
      threads: 8
```

**Environment Variables:**

| Variable | Description | Required |
|----------|-------------|----------|
| `SYNTHEA_DATA_PATH` | Path to Synthea CSV files | Yes |
| `DBT_DATABASE_PATH` | Path to local DuckDB file | No (default: `target/healthcare.duckdb`) |
| `MOTHERDUCK_TOKEN` | MotherDuck API token | Prod only |

**Schema Strategy:**
- Dev: All objects in `dev` schema
- Prod: Layer-based schemas (`data_lake`, `raw_vault`, `business_vault`, `info_mart`, `reference`)

### 8.8 Deployment (Future)

**MotherDuck Production:**
1. Create MotherDuck account and database
2. Configure `MOTHERDUCK_TOKEN` environment variable
3. Run dbt with `--target prod`
4. Schedule incremental runs (e.g., daily via GitHub Actions)

**Evidence.dev:**
1. Connect Evidence to MotherDuck database
2. Develop reports in `evidence/` directory
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

### 10.1 Dashboard Planning (TODO)

Evidence.dev dashboards to be designed and implemented:

**Claims Analytics:**
- Claims trends over time (monthly/quarterly volume and cost)
- Cost drivers by diagnosis category
- Claim status distribution and aging
- Payer mix and reimbursement rates

**Provider Analytics:**
- Provider performance scorecards
- Utilization by provider and specialty
- Cost per encounter by provider
- Network adequacy metrics

**Patient Analytics:**
- Patient cohort analysis by condition
- Population health metrics
- Care gap identification
- Patient journey visualization

**Operational Dashboards:**
- ETL load status and data freshness
- Data quality metrics and anomaly alerts
- Model run history and performance

---

**Document Version:** 1.1  
**Last Updated:** 2026-01-19  
**Maintained By:** Dan Brickey

**Change Log:**
- v1.1: Added Synthea data dictionary, satellite history tracking, data ingestion strategy, source configuration, Info Mart details, incremental loading, testing strategy, environment configuration, dashboard TODO
- v1.0: Initial specification
