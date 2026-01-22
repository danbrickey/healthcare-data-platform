# Healthcare Data Platform - Project Specification

> **Portfolio Project** demonstrating modern data engineering and healthcare analytics capabilities for payer and provider organizations.

---

## Executive Summary

This platform ingests, transforms, and analyzes healthcare data to deliver actionable insights across the payer-provider ecosystem. Built on modern data engineering principles (Data Vault 2.0, dbt, DuckDB), it showcases real-world analytics use cases including claims analysis, provider performance, population health, and regulatory reporting.

**Target Audience:** Hiring managers and technical interviewers in healthcare data engineering, analytics engineering, and data architecture roles.

**Skills Demonstrated:**
- Healthcare domain expertise (claims, clinical data, regulatory concepts)
- Modern data architecture (Data Vault 2.0, dimensional modeling)
- Analytics engineering (dbt, testing, documentation, lineage)
- Data integration (multiple source systems, reference data enrichment)
- Cloud-ready design (DuckDB → MotherDuck portability)
- Business intelligence (Evidence.dev dashboards)

---

## Table of Contents

1. [Vision & Objectives](#1-vision--objectives)
2. [Use Cases](#2-use-cases)
3. [Data Sources](#3-data-sources)
4. [Technical Architecture](#4-technical-architecture)
5. [Delivery Milestones](#5-delivery-milestones)
6. [Requirements](#6-requirements)
7. [Project Structure](#7-project-structure)
8. [Conventions & Standards](#8-conventions--standards)
9. [Out of Scope](#9-out-of-scope)
10. [Glossary](#10-glossary)

---

## 1. Vision & Objectives

### 1.1 Vision Statement

A production-ready healthcare data platform that demonstrates mastery of modern data engineering practices while solving real business problems faced by payers and providers.

### 1.2 Portfolio Objectives

| Objective | Demonstration |
|-----------|---------------|
| **Domain Knowledge** | Healthcare claims, clinical data, FHIR concepts, regulatory measures |
| **Architecture Design** | Data Vault 2.0 with clear separation of Raw Vault, Business Vault, Info Marts |
| **Data Engineering** | Incremental loading, change detection, late-arriving data handling |
| **Analytics Engineering** | dbt best practices, testing, documentation, lineage |
| **Data Integration** | Multiple sources (synthetic + public), reference data enrichment |
| **Business Intelligence** | Interactive dashboards with real analytical value |

### 1.3 Success Criteria

The project succeeds when an interviewer can:
1. **Explore the architecture** via dbt docs and understand the data flow
2. **Query the data** and see meaningful healthcare analytics
3. **Review the code** and see professional-quality SQL and project organization
4. **View dashboards** that tell compelling stories about the data
5. **Discuss design decisions** with the candidate using this spec as reference

---

## 2. Use Cases

The platform addresses analytics needs across the healthcare ecosystem. Each use case represents a distinct analytical capability that employers value.

### 2.1 Payer Analytics (Insurance Companies, Medicare/Medicaid)

| ID | Use Case | Business Value | Key Metrics |
|----|----------|----------------|-------------|
| **P1** | Claims Cost Analysis | Identify cost drivers and spending trends | Total cost, cost per member, cost by category |
| **P2** | Provider Network Performance | Evaluate provider efficiency and quality | Cost per episode, quality scores, utilization |
| **P3** | Member Risk Stratification | Predict high-cost members for care management | Risk scores, chronic condition flags, predicted cost |
| **P4** | Quality Measure Reporting | Track HEDIS-like quality measures | Measure rates, gaps in care, compliance % |
| **P5** | Geographic Access Analysis | Ensure network adequacy by region | Provider density, drive time, specialty coverage |

### 2.2 Provider Analytics (Hospitals, Health Systems, Physician Groups)

| ID | Use Case | Business Value | Key Metrics |
|----|----------|----------------|-------------|
| **V1** | Revenue Cycle Analytics | Optimize billing and collections | Days in A/R, denial rates, collection rates |
| **V2** | Patient Population Health | Manage chronic disease populations | Condition prevalence, care gaps, outcomes |
| **V3** | Operational Efficiency | Optimize resource utilization | Encounters per provider, procedure volumes |
| **V4** | Referral Pattern Analysis | Understand patient flow and leakage | Referral volumes, in-network %, top destinations |
| **V5** | Quality & Outcomes Reporting | Track clinical quality metrics | Readmission rates, complication rates, mortality |

### 2.3 Cross-Domain Analytics

| ID | Use Case | Business Value | Key Metrics |
|----|----------|----------------|-------------|
| **X1** | Cost Benchmarking | Compare costs to regional/national benchmarks | Cost vs. benchmark, percentile ranking |
| **X2** | Demographic Analysis | Understand population characteristics | Age/gender distribution, geographic patterns |
| **X3** | Temporal Trend Analysis | Track changes over time | YoY growth, seasonal patterns, trend lines |
| **X4** | Data Quality Monitoring | Ensure data completeness and accuracy | Completeness %, anomaly counts, freshness |

---

## 3. Data Sources

### 3.1 Primary: Synthea Synthetic Healthcare Data

**Source:** [Synthea™ Patient Generator](https://synthetichealth.github.io/synthea/)

Synthea generates realistic synthetic patient records from birth to death, including demographics, encounters, conditions, procedures, medications, and claims. All data is fictional but statistically representative of US healthcare patterns.

**Key Entities:**

| Entity | Description | Business Keys |
|--------|-------------|---------------|
| Patients | Demographics, coverage history | Patient UUID |
| Encounters | Office visits, hospital stays, ER visits | Encounter UUID |
| Conditions | Diagnoses with onset/resolution dates | Patient + Code + Start Date |
| Procedures | Medical procedures performed | Encounter + Code |
| Medications | Prescriptions and dispenses | Encounter + Code |
| Claims | Insurance claim headers | Claim UUID |
| Claim Lines | Individual services billed | Claim + Line Number |
| Providers | Physicians and practitioners | Provider UUID |
| Organizations | Hospitals, clinics, facilities | Organization UUID |
| Payers | Insurance companies | Payer UUID |

**Data Characteristics:**
- UUIDs for all entity identifiers
- Standard terminologies (ICD-10, CPT, SNOMED, RxNorm, LOINC)
- Temporal consistency (events in logical order)
- US Census-aligned demographics
- Configurable volume (target: 50,000 patients)

### 3.2 Public Reference Data: CMS

**Source:** [Centers for Medicare & Medicaid Services](https://data.cms.gov/)

| Dataset | Purpose | Use Cases |
|---------|---------|-----------|
| Medicare Provider Utilization | Real-world provider benchmarks | P2, X1 |
| Geographic Variation | Regional cost/utilization patterns | P5, X1, X2 |
| Quality Measures | HEDIS/CMS measure specifications | P4, V5 |
| Fee Schedules | Reimbursement rate references | P1, V1 |

### 3.3 Public Reference Data: Bureau of Labor Statistics

**Source:** [BLS Data](https://www.bls.gov/data/)

| Dataset | Purpose | Use Cases |
|---------|---------|-----------|
| Medical Care CPI | Healthcare cost inflation indices | X1, X3 |
| Employment by Industry | Healthcare workforce data | P5, V3 |
| Regional Price Parities | Geographic cost adjustments | X1, X2 |

### 3.4 Reference Data (Seeds)

Static reference tables loaded via dbt seeds:

| Seed | Description | Source |
|------|-------------|--------|
| `icd10_codes` | Diagnosis code descriptions | CMS |
| `cpt_codes` | Procedure code descriptions | AMA (public subset) |
| `loinc_codes` | Lab/observation codes | Regenstrief |
| `rxnorm_codes` | Medication codes | NLM |
| `place_of_service` | Service location types | CMS |
| `state_fips` | State codes and names | Census |
| `cms_regions` | CMS regional definitions | CMS |

---

## 4. Technical Architecture

### 4.1 Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Database** | DuckDB (local) / MotherDuck (cloud) | Fast OLAP, portable, cost-effective |
| **Transformation** | dbt Core | Industry standard, testable, documented |
| **Data Modeling** | Data Vault 2.0 via automate_dv | Scalable, auditable, flexible |
| **BI/Visualization** | Evidence.dev | Code-based, version-controlled, modern |
| **Version Control** | Git/GitHub | Standard collaboration |

### 4.2 Medallion Architecture

The platform uses a four-layer medallion architecture aligned with Data Vault 2.0:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PLATINUM (Views)                                                    │
│  Virtualized layer organized by use case / business process         │
│  Schema: platinum_*                                                  │
└─────────────────────────────────────────────────────────────────────┘
                                    ▲
┌─────────────────────────────────────────────────────────────────────┐
│  GOLD (Business Vault + Dimensional)                                │
│  Business rules, computed fields, facts/dimensions                  │
│  Schema: gold_business_vault, gold_dimensional                      │
└─────────────────────────────────────────────────────────────────────┘
                                    ▲
┌─────────────────────────────────────────────────────────────────────┐
│  SILVER (Raw Vault)                                                 │
│  Data Vault 2.0: Hubs, Links, Satellites                            │
│  Schema: silver_raw_vault                                           │
└─────────────────────────────────────────────────────────────────────┘
                                    ▲
┌─────────────────────────────────────────────────────────────────────┐
│  BRONZE (Data Lake)                                                 │
│  Raw source data, light cleaning, type casting                      │
│  Schema: bronze_data_lake                                           │
└─────────────────────────────────────────────────────────────────────┘
                                    ▲
┌─────────────────────────────────────────────────────────────────────┐
│  SOURCE DATA                                                         │
│  Synthea CSV, CMS Data, BLS Data                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Layer Definitions:**

| Layer | Schema | Purpose | Models |
|-------|--------|---------|--------|
| **Bronze** | `bronze_data_lake` | Raw source data, minimal transformation | `stg_<source>__<entity>` |
| **Silver** | `silver_raw_vault` | Data Vault 2.0 core structures | `h_*`, `l_*`, `s_*` |
| **Gold** | `gold_business_vault`, `gold_dimensional` | Business logic, dimensional models | `cs_*`, `brg_*`, `pit_*`, `dim_*`, `fct_*` |
| **Platinum** | `platinum_info_mart` | Virtualized views by use case | Use case-specific views |

### 4.3 Data Vault Design

**Core Hubs (Business Entities):**

| Hub | Business Key | Description |
|-----|--------------|-------------|
| `h_patient` | patient_id | Unique patients |
| `h_provider` | provider_id | Healthcare providers |
| `h_organization` | organization_id | Facilities/health systems |
| `h_encounter` | encounter_id | Patient visits |
| `h_claim` | claim_id | Insurance claims |
| `h_payer` | payer_id | Insurance payers |
| `h_diagnosis` | diagnosis_code | ICD-10 diagnosis codes |
| `h_procedure` | procedure_code | CPT procedure codes |
| `h_medication` | medication_code | RxNorm medication codes |

**Core Links (Relationships):**

| Link | Connects | Cardinality |
|------|----------|-------------|
| `l_encounter_patient` | Encounter ↔ Patient | M:1 |
| `l_encounter_provider` | Encounter ↔ Provider | M:1 |
| `l_encounter_organization` | Encounter ↔ Organization | M:1 |
| `l_claim_encounter` | Claim ↔ Encounter | M:1 |
| `l_claim_patient` | Claim ↔ Patient | M:1 |
| `l_claim_diagnosis` | Claim ↔ Diagnosis | M:M |
| `l_claim_procedure` | Claim ↔ Procedure | M:M |
| `l_patient_payer` | Patient ↔ Payer | M:M (temporal) |
| `l_provider_organization` | Provider ↔ Organization | M:1 |

**Key Satellites (Attributes):**

| Satellite | Parent | Attributes |
|-----------|--------|------------|
| `s_patient_demographics` | h_patient | Name, DOB, gender, race, ethnicity |
| `s_patient_address` | h_patient | Address, city, state, zip, coordinates |
| `s_encounter_details` | h_encounter | Type, dates, costs, reason |
| `s_claim_header` | h_claim | Status, dates, totals |
| `s_claim_line` | h_claim | Service details, amounts (multi-active) |
| `s_provider_details` | h_provider | Name, specialty, credentials |
| `s_organization_details` | h_organization | Name, type, address, utilization |
| `s_condition_record` | l_encounter_patient | Condition codes, onset, resolution |

---

## 5. Delivery Milestones

The project is delivered in phases. Each milestone is independently valuable for portfolio demonstration.

### Milestone 0: Phase Zero - Foundation Setup

**Goal:** Establish foundational infrastructure and development environment

| Deliverable | Description |
|-------------|-------------|
| DuckDB Setup | Database file created, schemas initialized for all medallion layers |
| dbt Configuration | Project configured with automate_dv, medallion schema naming |
| Synthea Data Generation | Scripts to generate sample healthcare data |
| Source Definitions | dbt sources configured for Synthea CSV files |
| Development Environment | dbt installed, IDE extensions configured |
| Setup Documentation | Developer guide for local environment setup |

**Verification:**
- `dbt debug` succeeds with DuckDB connection
- Synthea CSV files exist in `data/synthea/`
- `dbt deps` installs packages successfully
- All medallion schemas created in DuckDB

### Milestone 1: Foundation (MVP)
**Goal:** End-to-end data flow with basic claims analytics

| Deliverable | Description |
|-------------|-------------|
| Data Lake Layer | Staging models for all Synthea entities |
| Core Raw Vault | Patient, Provider, Organization, Encounter, Claim hubs + key links/sats |
| Basic Info Mart | `dim_patient`, `dim_provider`, `fct_claim_line` |
| Claims Dashboard | Total claims, cost trends, top diagnoses |
| Tests & Docs | Primary key tests, model descriptions, dbt docs site |

**Use Cases Enabled:** P1 (basic), X2, X3, X4

### Milestone 2: Clinical Depth
**Goal:** Expand clinical data and enable population health analytics

| Deliverable | Description |
|-------------|-------------|
| Clinical Vault | Conditions, procedures, medications, observations satellites |
| Patient Mart | `patient_condition_summary`, `patient_encounter_history` |
| Condition Analytics | Prevalence by condition, chronic disease identification |
| Quality Foundations | Basic care gap identification |

**Use Cases Enabled:** V2, P3 (basic), P4 (foundation)

### Milestone 3: Provider & Network Analytics
**Goal:** Provider performance and network analysis capabilities

| Deliverable | Description |
|-------------|-------------|
| Provider Mart | `provider_utilization`, `provider_cost_metrics` |
| Organization Mart | `organization_summary`, `facility_utilization` |
| Network Analysis | Provider density by geography, specialty coverage |
| Referral Patterns | Patient flow between providers/organizations |

**Use Cases Enabled:** P2, P5, V3, V4

### Milestone 4: External Data Integration
**Goal:** Enrich with public data for benchmarking and context

| Deliverable | Description |
|-------------|-------------|
| CMS Integration | Medicare utilization data, quality benchmarks |
| BLS Integration | Cost indices, regional adjustments |
| Benchmark Models | Cost comparisons to external benchmarks |
| Geographic Enrichment | Regional cost adjustments, access scoring |

**Use Cases Enabled:** X1, P5 (enhanced)

### Milestone 5: Advanced Analytics & Polish
**Goal:** Sophisticated analytics and comprehensive dashboards

| Deliverable | Description |
|-------------|-------------|
| Risk Stratification | Patient risk scores, predicted cost |
| Quality Measures | HEDIS-like measure calculations |
| Revenue Cycle | Denial patterns, payment timing |
| Executive Dashboards | Polished, presentation-ready visualizations |

**Use Cases Enabled:** P3 (full), P4 (full), V1, V5

---

## 6. Requirements

### 6.1 Functional Requirements

#### Data Ingestion (ING)

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| ING-01 | Load Synthea CSV files via dbt sources | Must | M1 |
| ING-02 | Support incremental loading for large tables | Must | M1 |
| ING-03 | Ingest CMS public datasets | Should | M4 |
| ING-04 | Ingest BLS reference data | Should | M4 |
| ING-05 | Handle late-arriving data correctly | Must | M2 |

#### Data Modeling (MOD)

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| MOD-01 | Implement Data Vault 2.0 with automate_dv | Must | M1 |
| MOD-02 | All hubs, links, satellites include audit columns | Must | M1 |
| MOD-03 | Satellites track full history with hashdiff | Must | M1 |
| MOD-04 | PIT tables for efficient temporal queries | Should | M2 |
| MOD-05 | Bridge tables for complex relationship queries | Should | M3 |
| MOD-06 | Info Marts use dimensional modeling | Must | M1 |

#### Analytics (ANA)

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| ANA-01 | Claims cost analysis by multiple dimensions | Must | M1 |
| ANA-02 | Patient demographic analysis | Must | M1 |
| ANA-03 | Provider utilization metrics | Must | M3 |
| ANA-04 | Condition prevalence and trends | Should | M2 |
| ANA-05 | Risk stratification scoring | Could | M5 |
| ANA-06 | Quality measure calculations | Could | M5 |
| ANA-07 | Cost benchmarking vs. external data | Should | M4 |

#### Visualization (VIZ)

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| VIZ-01 | Evidence.dev project with DuckDB connection | Must | M1 |
| VIZ-02 | Claims analytics dashboard | Must | M1 |
| VIZ-03 | Patient population dashboard | Should | M2 |
| VIZ-04 | Provider performance dashboard | Should | M3 |
| VIZ-05 | Executive summary dashboard | Could | M5 |

### 6.2 Non-Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-01 | All models have descriptions in schema.yml | Must |
| NFR-02 | Primary keys tested for uniqueness and not-null | Must |
| NFR-03 | Foreign keys tested with relationship tests | Must |
| NFR-04 | dbt docs generate produces complete documentation | Must |
| NFR-05 | Models follow naming conventions consistently | Must |
| NFR-06 | Incremental models complete within reasonable time (< 5 min for 50K patients) | Should |
| NFR-07 | Dashboard queries return within 3 seconds | Should |

---

## 7. Project Structure

```
healthcare-data-platform/
├── SPECIFICATION.md              # This document
├── README.md                     # Setup and quick start
├── CONTRIBUTING.md               # Contribution guidelines
│
├── data/                         # Data files (gitignored)
│   ├── synthea/                  # Synthea CSVs
│   ├── cms/                      # CMS public data
│   └── bls/                      # BLS reference data
│
├── dbt/                          # dbt project
│   ├── dbt_project.yml
│   ├── packages.yml              # automate_dv, dbt_utils
│   ├── profiles.yml.example
│   │
│   ├── models/
│   │   ├── 1_bronze_data_lake/   # Bronze layer (data lake)
│   │   │   └── _sources.yml      # Source definitions
│   │   ├── 2_silver_raw_vault/   # Silver layer (raw vault)
│   │   │   ├── hubs/             # h_* models
│   │   │   ├── links/            # l_* models
│   │   │   └── sats/             # s_* models
│   │   ├── 3_gold_business_vault/ # Gold layer (business vault + dimensional)
│   │   │   ├── business_vault/   # cs_*, brg_*, pit_*
│   │   │   └── dimensional/      # dim_*, fct_*
│   │   └── 4_platinum_info_mart/ # Platinum layer (info marts/views)
│   │       └── use_cases/        # Use case organized views
│   │
│   ├── macros/                   # Custom macros
│   ├── seeds/                    # Reference data CSVs
│   ├── tests/                    # Custom tests
│   └── analyses/                 # Ad-hoc queries
│
├── evidence/                     # Evidence.dev project
│   ├── pages/                    # Dashboard pages
│   └── sources/                  # Data connections
│
├── scripts/                      # Utility scripts
│   ├── generate_synthea_data.ps1 # Windows data generation
│   ├── generate_synthea_data.sh  # Unix data generation
│   └── setup_database.sql        # DuckDB schema setup
│
├── docs/                         # Additional documentation
│   ├── setup_guide.md            # Developer setup instructions
│   ├── planning_notes.md
│   └── context/                  # AI context files
│       └── pattern_automate_dv.md # AutomateDV patterns
│
└── ai-resources/                 # AI assistant resources
```

---

## 8. Conventions & Standards

### 8.0 Documentation Standards

All project documentation follows AI-friendly patterns for consistent code generation and human readability.

**Format Standards:**

| Format | Usage | Example |
|--------|-------|---------|
| Structured Data | YAML, CSV | Configuration files, data dictionaries |
| Prose | Markdown (minimal verbosity) | Specifications, guides |
| Diagrams | Mermaid or ASCII art | Architecture diagrams (no external images) |

**Principles:**

- Concise over verbose
- Examples over explanations
- Tables for structured information
- Code blocks for patterns
- Expandable sections for details

**AI-Friendly Guidelines:**

- Consistent heading structure (H1 → H2 → H3)
- Clear section markers and delimiters
- Template patterns with `<placeholders>`
- Entity maps and quick reference tables
- No ambiguous language or jargon without definition
- Code examples use realistic healthcare entities

**Documentation Structure:**

```yaml
# Standard documentation pattern
title: "Clear, descriptive title"
overview: "One-sentence purpose"
sections:
  - conventions: "Naming, formatting rules"
  - examples: "Copy-paste ready code"
  - reference: "Quick lookup tables"
  - patterns: "Reusable templates"
```

### 8.1 Naming Conventions

**General Rule:** All names use `lower_snake_case`.

| Object Type | Pattern | Example |
|-------------|---------|---------|
| Data Lake models | `stg_<source>__<entity>` | `stg_synthea__patients` |
| Hubs | `h_<entity>` | `h_patient` |
| Links | `l_<entity1>_<entity2>` | `l_claim_patient` |
| Satellites | `s_<parent>_<context>` | `s_patient_demographics` |
| Computed Satellites | `cs_<parent>_<context>` | `cs_patient_risk_score` |
| Bridges | `brg_<entity1>_<entity2>` | `brg_claim_diagnosis` |
| PIT Tables | `pit_<entity>` | `pit_patient` |
| Dimensions | `dim_<entity>` | `dim_patient` |
| Facts | `fct_<entity>` | `fct_claim_line` |
| Aggregates | `<domain>_<metric>_<grain>` | `claims_cost_monthly` |

### 8.2 Column Naming

| Column Type | Pattern | Example |
|-------------|---------|---------|
| Hash keys | `hk_<entity>` | `hk_patient` |
| Business keys | `<entity>_id` | `patient_id` |
| Dates | `<event>_date` | `service_date` |
| Timestamps | `<event>_at` | `created_at` |
| Amounts | `<type>_amount` | `charge_amount` |
| Codes | `<type>_code` | `diagnosis_code` |
| Flags | `is_<condition>` | `is_active` |
| Counts | `<entity>_count` | `claim_count` |

### 8.3 SQL Style

- Lowercase keywords
- Leading commas
- CTEs for readability
- Descriptive CTE names
- 4-space indentation

### 8.4 Testing Standards

| Test Type | Applied To |
|-----------|------------|
| `unique` | All primary keys |
| `not_null` | All primary keys, required business fields |
| `relationships` | All foreign key references |
| `accepted_values` | Categorical fields (status, type, gender) |

---

## 9. Out of Scope

The following are explicitly **not** included in this project:

| Item | Reason |
|------|--------|
| Real PHI/PII data | Compliance risk; synthetic data sufficient for demo |
| HIPAA compliance infrastructure | Portfolio project, not production |
| Real-time streaming | Batch processing demonstrates core skills |
| ML model training/deployment | Focus is on data engineering, not data science |
| Production deployment automation | CI/CD is secondary to core data work |
| Multi-tenant architecture | Single-tenant sufficient for demonstration |
| User authentication/authorization | BI tool handles access for demo purposes |

---

## 10. Glossary

| Term | Definition |
|------|------------|
| **Claim** | A request for payment submitted to an insurance payer for healthcare services |
| **CPT** | Current Procedural Terminology - codes for medical procedures |
| **Data Vault** | A data modeling methodology emphasizing auditability and flexibility |
| **Encounter** | A patient's interaction with the healthcare system (visit, admission) |
| **HEDIS** | Healthcare Effectiveness Data and Information Set - quality measures |
| **Hub** | Data Vault entity containing business keys |
| **ICD-10** | International Classification of Diseases - diagnosis codes |
| **Link** | Data Vault entity representing relationships between hubs |
| **LOINC** | Logical Observation Identifiers Names and Codes - lab/observation codes |
| **Payer** | Insurance company or government program that pays for healthcare |
| **PIT** | Point-in-Time table for efficient temporal queries |
| **Provider** | Healthcare professional or facility delivering care |
| **RxNorm** | Standardized nomenclature for clinical drugs |
| **Satellite** | Data Vault entity containing descriptive attributes |
| **SNOMED-CT** | Systematized Nomenclature of Medicine - clinical terminology |
| **Synthea** | Open-source synthetic patient data generator |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | 2026-01-21 | Dan Brickey | Complete restructure as portfolio specification |
| 1.1 | 2026-01-19 | Dan Brickey | Added Synthea details, testing, environments |
| 1.0 | — | Dan Brickey | Initial specification |

---

*This specification defines the Healthcare Data Platform portfolio project. Implementation details, code templates, and developer guides are maintained separately in `docs/developer_guide.md`.*
