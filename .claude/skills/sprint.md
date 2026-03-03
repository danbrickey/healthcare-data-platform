---
name: sprint
description: >
  Sprint planner for the healthcare-data-platform. Creates milestones, assigns issues
  to sprints, and tracks velocity. Invoke with /sprint or when the user says "start a
  new sprint", "plan the sprint", or "what's in this sprint?"
---

# /sprint — Sprint Planner

## Purpose

Plan and manage weekly sprints using GitHub Milestones + the project board. Create new
sprints, commit work items, and track velocity over time.

## Context

- **Repo**: `danbrickey/healthcare-data-platform`
- **Project config**: `.github/project-config.json`
- **Sprint cadence**: Weekly (Sunday → Saturday)
- **Velocity file**: `docs/planning/velocity.md` — running record of sprint velocity

## Process

### Start a New Sprint

1. **Determine sprint dates**: Calculate the current week's Sunday → Saturday
2. **Create milestone**:
   ```bash
   gh api repos/danbrickey/healthcare-data-platform/milestones \
     --method POST \
     -f title="Sprint N (YYYY-MM-DD → YYYY-MM-DD)" \
     -f due_on="YYYY-MM-DDT23:59:59Z" \
     -f description="Goal: [sprint goal]"
   ```
3. **Pull from backlog**: Fetch items in "Ready" status from the board, sorted by priority
4. **Propose commitment**: Show available items with points, suggest which to commit based on target velocity
5. **After approval**: Assign milestone to committed issues and move them to "Ready" on the board

### Check Current Sprint

1. Fetch the current milestone (most recent open)
2. List all issues in the milestone with their status
3. Calculate: committed points, completed points, remaining points
4. Show progress summary

### Close Sprint / Retrospective

1. Fetch all issues in the milestone
2. Calculate velocity: points completed this sprint
3. List incomplete items (carry over to next sprint?)
4. Update `docs/planning/velocity.md`:
   ```markdown
   | Sprint | Dates | Committed | Completed | Velocity | Notes |
   |--------|-------|-----------|-----------|----------|-------|
   | Sprint 1 | 03/03 → 03/09 | 21 | 18 | 18 | First sprint |
   ```
5. Close the milestone
6. Ask: create next sprint now?

## Velocity Tracking

Maintain `docs/planning/velocity.md` as a running record:

```markdown
# Velocity Tracking

## Sprint History

| Sprint | Dates | Committed | Completed | Carry-Over | Notes |
|--------|-------|-----------|-----------|------------|-------|

## Rolling Average

**Last 3 sprints**: X points/sprint
**Target next sprint**: X points
```

Use rolling 3-sprint average for capacity planning.

## Important Notes

- Sprint = GitHub Milestone + project board status management
- Read project-config.json fresh for field/option IDs
- Always propose sprint commitment for approval — don't auto-assign
- Track velocity in the repo so it persists and is visible
- One week sprints align with Dan's planning-assistant skill patterns
