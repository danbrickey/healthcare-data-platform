---
name: groom
description: >
  Backlog groomer for the healthcare-data-platform. Reviews the project board, identifies
  stale/blocked/unestimated items, and suggests re-prioritization. Invoke with /groom or
  when the user says "review the backlog", "what should we work on next?", or "prioritize".
---

# /groom — Backlog Groomer

## Purpose

Review the current state of the project board, identify issues that need attention, and
suggest prioritization for upcoming work.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json`

## Process

### Step 1: Fetch Board State

Read `.github/project-config.json` for project ID.

Fetch all items from the project board:
```bash
gh api graphql -f query='query {
  node(id: "{PROJECT_ID}") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
              title
              state
              labels(first: 10) { nodes { name } }
              createdAt
              updatedAt
            }
          }
          fieldValues(first: 10) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field { ... on ProjectV2SingleSelectField { name } }
              }
            }
          }
        }
      }
    }
  }
}'
```

### Step 2: Analyze

Categorize items and flag issues:

**Health Checks:**
- Items in Backlog with no points estimate
- Items in Backlog older than 2 weeks (stale)
- Items marked Blocked — what's blocking them?
- Items In Progress for more than 1 week without updates
- Items without a layer or priority assigned

**Board Summary:**
| Status | Count | Points |
|--------|-------|--------|
| Backlog | X | XX |
| Ready | X | XX |
| In Progress | X | XX |
| In Review | X | XX |
| Done | X | XX |
| Blocked | X | XX |

### Step 3: Suggest Prioritization

Based on:
1. **Dependencies**: What unblocks the most other work?
2. **Phase plan**: What's next in the healthcare data platform roadmap?
3. **Value**: What delivers the most portfolio/demo value?
4. **Momentum**: What's closest to done?

Propose a ranked list of "next up" items to move from Backlog → Ready.

### Step 4: Present

Show the user:
1. Board health summary (counts, points by status)
2. Flagged issues (stale, missing estimates, blocked)
3. Recommended next items (ranked, with rationale)
4. Any suggested new items to add based on project gaps

Ask: "Want me to move any of these to Ready, update priorities, or create new items?"

### Step 5: Execute Changes

If the user approves changes:
- Move items between statuses
- Update priorities
- Add missing estimates
- Create new items as needed

## Important Notes

- This is a review/advisory skill — always present findings before making changes
- Read project-config.json fresh for field/option IDs
- Consider the project's SPECIFICATION.md milestones when prioritizing
- Be concise — the user wants a quick health check, not a novel
