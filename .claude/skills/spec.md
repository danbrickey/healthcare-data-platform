---
name: spec
description: >
  Structured spec writer for the healthcare-data-platform. Creates a specification
  document and a linked GitHub issue on the project board. Invoke with /spec or when
  the user says "write a spec", "spec this out", or "I need to build..."
---

# /spec — Structured Spec Writer

## Purpose

Write a structured specification for a work item, create the spec as a markdown file in
`docs/specs/`, create a GitHub issue, add it to the project board, and link them together.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json` — contains project ID, field IDs, and option IDs for the GitHub Projects board
- **Specs folder**: `docs/specs/`
- **Issue templates**: `.github/ISSUE_TEMPLATE/`

## Process

### Step 1: Gather Context

If the user hasn't provided enough detail, briefly interview for:
1. **What** needs to be built (the capability)
2. **Why** it matters (the value)
3. **Type**: Epic, Feature, Story, Bug, or Spike

Don't over-interview. Infer from conversation context when possible. If the user gave a
clear description, skip straight to writing.

### Step 2: Write the Spec

Create a markdown file at `docs/specs/{type}-{short_slug}.md` with this structure:

```markdown
---
title: [Concise title]
type: [epic|feature|story|bug|spike]
issue: # [will be filled after issue creation]
status: draft
points: [Fibonacci: 1,2,3,5,8,13 — stories/bugs only]
priority: [critical|high|medium|low]
layer: [bronze|silver|gold|platinum|infrastructure]
parent: # [issue number of parent, if applicable]
created: [YYYY-MM-DD]
---

# [Title]

## Problem

[What problem does this solve? Why does it matter? 2-3 sentences.]

## Solution

[How will we solve it? High-level approach. 3-5 sentences.]

## Acceptance Criteria

- [ ] Given [precondition], when [action], then [expected result]
- [ ] Given [precondition], when [action], then [expected result]

## Technical Design

[Implementation approach. Which files to modify, patterns to follow, dependencies.
For dbt models: include model name, materialization, source references, test strategy.]

## Out of Scope

[What this spec explicitly does NOT cover.]

## Open Questions

[Anything unresolved that needs discussion before implementation.]
```

### Step 3: Create the GitHub Issue

Read `.github/project-config.json` for project and field IDs.

Create the issue using `gh issue create`:
- Title matches the spec title
- Apply appropriate labels: `type: {type}`, `layer: {layer}`, `priority: {priority}`
- Body contains the User Story format (for stories) or Problem/Solution summary
- Include a link back to the spec file: `**Spec**: docs/specs/{filename}`

### Step 4: Add to Project Board

After creating the issue:

1. Add the issue to the project board:
   ```bash
   gh project item-add {PROJECT_NUMBER} --owner {OWNER} --url {ISSUE_URL}
   ```

2. Query for the item ID:
   ```bash
   gh api graphql -f query='query {
     node(id: "{PROJECT_ID}") {
       ... on ProjectV2 { items(last: 1) { nodes { id } } }
     }
   }'
   ```

3. Set custom fields (Type, Points, Priority, Layer) using the option IDs from project-config.json:
   ```bash
   gh api graphql -f query='mutation {
     updateProjectV2ItemFieldValue(input: {
       projectId: "{PROJECT_ID}",
       itemId: "{ITEM_ID}",
       fieldId: "{FIELD_ID}",
       value: { singleSelectOptionId: "{OPTION_ID}" }
     }) { projectV2Item { id } }
   }'
   ```

4. Set status to "Backlog" (or "Ready" if the user indicates it's urgent).

### Step 5: Update the Spec

Update the spec file's front matter with the issue number:
```yaml
issue: '#42'
```

### Step 6: Confirm

Report to the user:
- Spec file path
- Issue URL
- Board status
- Points estimate with brief justification

## Sizing Rubric (Fibonacci)

| Points | Complexity | Data Platform Examples |
|--------|-----------|----------------------|
| 1 | Trivial | Fix a YAML typo, update a config value |
| 2 | Simple | Add a column to a staging model, update a source description |
| 3 | Small | Create a single hub or satellite model with tests |
| 5 | Medium | Create a hub + link + satellite group, a dimensional model with joins |
| 8 | Large | Full entity group (hub + links + satellites + staging), a complete PIT table |
| 13 | Very Large | Full medallion layer for a new entity, complex business logic |

If the estimate is 13+, suggest decomposition into smaller stories.

## Important Notes

- Always read `project-config.json` fresh — don't hardcode IDs
- Use `gh` CLI for all GitHub operations
- Specs are version-controlled markdown, not throwaway notes
- Link specs ↔ issues bidirectionally (spec front matter has issue #, issue body has spec path)
- For dbt-specific stories, reference the SPECIFICATION.md naming conventions
