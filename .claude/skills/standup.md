---
name: standup
description: >
  Session summary for the healthcare-data-platform. Summarizes what was accomplished,
  what's blocked, and what to focus on next. Invoke with /standup or at the end of a
  work session, or when the user says "what did we do?", "session summary", or "standup".
---

# /standup — Session Summary

## Purpose

Generate a concise summary of what happened this session. Report on issues touched,
status changes, code produced, and suggest next steps.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json`

## Process

### Step 1: Gather Session Activity

Collect from multiple sources:

1. **Git activity** (this session):
   ```bash
   git log --since="today" --oneline --all
   git diff --stat HEAD
   git status
   ```

2. **Issues touched** — check recent issue activity:
   ```bash
   gh issue list --repo danbrickey/healthcare-data-platform \
     --state all --limit 20 --json number,title,state,updatedAt,labels
   ```

3. **Current sprint** — check milestone progress:
   ```bash
   gh api repos/danbrickey/healthcare-data-platform/milestones --jq '.[0]'
   ```

4. **Conversation context** — what was discussed and decided this session

### Step 2: Generate Summary

Format:

```markdown
## Session Summary — [Date]

### Completed
- [x] #XX — [Title] (moved to Done, X points)
- [x] Created spec for [item]

### In Progress
- [ ] #YY — [Title] (started, X points remaining)

### Blocked
- [ ] #ZZ — [Title] — blocked on [reason]

### Decisions Made
- [Decision about architecture/approach]

### Next Session
- Suggested focus: [highest priority ready item]
- Open questions: [anything unresolved]

### Sprint Progress
- Sprint N: X/Y points completed (Z%)
```

### Step 3: Present

Show the summary. Don't write it to a file unless the user asks — it's primarily
a conversation artifact.

If the user wants it persisted, append to `docs/planning/session_log.md`.

## Important Notes

- Keep it concise — this is a quick status check, not a report
- Use the conversation context to capture decisions that aren't in git
- Focus on what matters: what moved, what's stuck, what's next
- If nothing was accomplished (pure discussion session), note key decisions instead
