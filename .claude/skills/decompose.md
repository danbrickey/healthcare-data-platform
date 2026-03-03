---
name: decompose
description: >
  Breaks epics into features and features into stories for the healthcare-data-platform.
  Creates child GitHub issues linked to the parent, adds them to the project board with
  estimates. Invoke with /decompose or when the user says "break this down", "decompose",
  or "what stories do we need?"
---

# /decompose — Epic/Feature Decomposer

## Purpose

Take an epic or feature (either an existing GitHub issue or a description) and decompose
it into well-sized child work items. Create the child issues, link them to the parent,
add them to the project board with Fibonacci estimates.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json`
- **Sizing guide**: Use the Fibonacci rubric below
- **SPECIFICATION.md**: Reference for domain entities, naming conventions, and architecture

## Process

### Step 1: Identify the Parent

Determine what to decompose:
- If the user references an issue number (`#XX`), fetch it: `gh issue view XX --repo danbrickey/healthcare-data-platform`
- If the user describes something new, identify whether it's epic-level or feature-level
- Read the parent's spec file if one exists (check `docs/specs/`)

### Step 2: Analyze and Propose Decomposition

**For Epics → Features:**
- Identify logical capability boundaries
- Each feature should deliver independent value
- Consider medallion layer boundaries (a feature per layer is often natural)
- Propose 3-8 features (fewer is better)

**For Features → Stories:**
- Each story should be completable in one session (ideally 1-5 points)
- Follow the vertical slice pattern where possible (staging → vault → test)
- Consider natural dbt model boundaries (one hub = one story, one satellite = one story)
- Include infrastructure stories (source definitions, tests, documentation)
- Flag anything 13+ for further decomposition

**Data Platform Decomposition Patterns:**
- **Per-entity vertical**: staging model → hub → satellite → link → tests (each can be a story)
- **Per-layer horizontal**: all staging models for a source, all hubs for a domain
- **Infrastructure**: source definitions, test suites, documentation, CI updates

### Step 3: Present for Approval

Show the proposed decomposition as a table:

```
Parent: #XX — [Title]

| # | Title | Type | Points | Priority | Layer | Notes |
|---|-------|------|--------|----------|-------|-------|
| 1 | ... | Story | 3 | High | Silver | ... |
| 2 | ... | Story | 5 | High | Silver | ... |
| 3 | ... | Story | 2 | Medium | Silver | ... |
```

Total points: XX
Estimated sprint capacity needed: XX

Ask the user: "Does this decomposition look right? I can adjust before creating the issues."

### Step 4: Create Child Issues

After approval, for each child item:

1. Create the issue with `gh issue create`:
   - Title: the proposed title
   - Labels: `type: story` (or feature), layer label, priority label
   - Body: User story format + link to parent (`Part of #XX`)

2. Add to project board and set custom fields (Type, Points, Priority, Layer, Status=Backlog)

3. If GitHub sub-issues are supported, link as sub-issue of parent

### Step 5: Update Parent

Add a comment to the parent issue listing all created children:

```markdown
## Decomposition

Created the following child issues:

- [ ] #A — [Title] (X points)
- [ ] #B — [Title] (X points)
- [ ] #C — [Title] (X points)

**Total**: XX points
```

### Step 6: Confirm

Report to the user:
- Number of items created
- Total points
- Links to all new issues
- Suggested sprint assignment if applicable

## Fibonacci Sizing Rubric (Data Platform Context)

| Points | Data Platform Examples |
|--------|----------------------|
| 1 | Fix a YAML typo, update a config value, add a column alias |
| 2 | Add a column to staging, update a source description, add a simple test |
| 3 | Create a single hub or satellite with AutomateDV, add source freshness |
| 5 | Hub + link pair, staging model with complex type casting, dimensional model |
| 8 | Full entity group (hub + links + sats + staging + tests), PIT table |
| 13 | Full layer for new domain, complex business logic, new data source integration |

## Important Notes

- Always present decomposition for approval BEFORE creating issues
- Read project-config.json fresh for field/option IDs
- Reference SPECIFICATION.md for correct entity names and naming conventions
- Link children to parent bidirectionally (child body references parent, parent comment lists children)
- Default new items to "Backlog" status unless the user says otherwise
