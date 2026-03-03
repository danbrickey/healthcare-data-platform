---
name: bug
description: >
  Quick bug reporter for the healthcare-data-platform. Creates a bug report as a GitHub
  issue and adds it to the project board. Invoke with /bug or when the user says "found
  a bug", "this is broken", or reports a dbt/test failure.
---

# /bug — Quick Bug Reporter

## Purpose

Quickly capture a bug as a GitHub issue, add it to the project board with appropriate
priority, and link to any related work items.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json`

## Process

### Step 1: Capture the Bug

From the conversation context, extract:
1. **What's broken** — one sentence
2. **Expected behavior** — what should happen
3. **Actual behavior** — what happens instead
4. **Error output** — any error messages, dbt logs, stack traces from the current session
5. **Related issue** — if the bug was discovered while working on a story/feature

If the user just said something like "dbt run failed" or "this test is broken", gather
the details from the current session context (recent command output, file being edited, etc.)
rather than interviewing.

### Step 2: Assess Priority

| Priority | Criteria |
|----------|----------|
| Critical | Blocks all work. Pipeline completely broken. Data corruption risk. |
| High | Blocks current story/sprint. Wrong data being produced. |
| Medium | Incorrect behavior but workaround exists. Non-blocking. |
| Low | Cosmetic. Documentation. Edge case that rarely triggers. |

### Step 3: Create the Issue

Read `.github/project-config.json` for project and field IDs.

Create the issue:
```bash
gh issue create \
  --repo danbrickey/healthcare-data-platform \
  --title "Bug: [concise description]" \
  --label "type: bug,priority: {priority}" \
  --body "[bug report body]"
```

Body format:
```markdown
## Description
[One sentence: what's broken]

## Expected Behavior
[What should happen]

## Actual Behavior
[What happens instead]

## Reproduction Steps
1. [step]
2. [step]

## Error Output
```
[paste error]
```

## Related Issues
[#XX if applicable]
```

### Step 4: Add to Board

1. Add issue to project: `gh project item-add {PROJECT_NUMBER} --owner {OWNER} --url {ISSUE_URL}`
2. Set custom fields:
   - Type: Bug
   - Priority: {assessed priority}
   - Points: estimate (bugs are usually 1-3 points)
   - Layer: if applicable
   - Status: "Ready" (bugs default to Ready, not Backlog)

### Step 5: Confirm

Report to the user:
- Issue URL
- Priority assessment
- Whether it blocks current work
- Suggested next action (fix now if Critical/High, or continue current work if Medium/Low)

## Important Notes

- Bugs default to "Ready" status — they're pre-triaged by the agent
- Critical bugs should be flagged prominently so the user can decide to pivot
- If the bug was found while working on a story, mention it in both the bug and the story
- Always include actual error output when available — don't summarize it away
- Read project-config.json fresh for every invocation
