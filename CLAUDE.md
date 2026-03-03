# Healthcare Data Platform — Claude Code Instructions

## Project Overview

A portfolio project demonstrating modern data engineering: DuckDB + dbt + AutomateDV (Data Vault 2.0) with a 4-layer medallion architecture (Bronze → Silver → Gold → Platinum).

## Key Files

- **SPECIFICATION.md** — Full technical spec, naming conventions, entity definitions
- **CONTRIBUTING.md** — Developer setup guide
- **docs/planning/phase_00/_plan.md** — Current phase plan
- **.github/project-config.json** — GitHub Projects board field IDs (used by skills)

## Agentic Workflow

This project uses GitHub Projects + Claude Code skills for work tracking.

**Board**: https://github.com/users/danbrickey/projects/2

**Available skills:**
- `/spec` — Write a structured specification and create a linked GitHub issue
- `/decompose` — Break an epic/feature into child issues with Fibonacci estimates
- `/groom` — Review the backlog, flag issues, suggest prioritization
- `/sprint` — Plan sprints, track velocity via milestones
- `/bug` — Quick bug reporting with auto-triage
- `/standup` — Session summary of what was accomplished

**Work item hierarchy:** Epic → Feature → Story (tracked via GitHub Issues + labels)

**Specs live in:** `docs/specs/` — linked to GitHub issues via front matter

## Naming Conventions (from SPECIFICATION.md)

- Data lake: `stg_<source>__<entity>`
- Hubs: `h_<entity>`
- Links: `l_<entity1>_<entity2>`
- Satellites: `s_<parent>_<context>`
- Dimensions: `dim_<entity>`
- Facts: `fct_<entity>`

## dbt Commands

```bash
cd dbt
dbt deps          # Install packages
dbt debug         # Test connection
dbt build         # Run all models + tests
dbt run -s +model_name  # Run model with upstream deps
dbt test -s model_name  # Test specific model
```
