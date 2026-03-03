# Agentic Workflow System — Proposal

> **Project**: Healthcare Data Platform
> **Type**: Workflow Infrastructure
> **Status**: Approved — Implementing Phase 1 (GitHub-Native + Skills)
> **Date**: 2026-03-02
> **Decision**: Phased hybrid approach. Start with System 3 (GitHub board + skills), evaluate graduation to System 2 (Plane.so) or System 1 (Custom Supabase) based on real usage data.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Three System Proposals](#three-system-proposals)
   - [System 1: "The Bespoke Workshop" — Custom Supabase App](#system-1-the-bespoke-workshop)
   - [System 2: "The Augmented Platform" — Plane.so + MCP](#system-2-the-augmented-platform)
   - [System 3: "The Lean Machine" — GitHub-Native](#system-3-the-lean-machine)
3. [Comparative Grading](#comparative-grading)
4. [Commercial Landscape](#commercial-landscape)
5. [Detailed System Designs](#detailed-system-designs)
   - [System 1 Detail](#system-1-detail)
   - [System 2 Detail](#system-2-detail)
   - [System 3 Detail](#system-3-detail)
6. [Skills Layer (Common to All Systems)](#skills-layer)
7. [Recommended Path Forward](#recommended-path-forward)
8. [Verification Plan](#verification-plan)

---

## Executive Summary

### The Problem

The healthcare-data-platform currently tracks work in static markdown files (`docs/planning/phase_00/_plan.md`). This works for linear, sequential phases but breaks down as the project grows — there's no visual board, no dynamic status tracking, no structured spec workflow, and no way for Claude Code to update progress as it works.

### What We Need

An **agentic workflow system** where:
- Work is organized as **Epics > Features > Stories** with a visual **Kanban board**
- Claude Code is a **first-class participant** — it can read the backlog, write specs, update statuses, and report progress through tool integrations (MCP servers, CLI, API)
- **Spec writing** is a structured process (problem → solution → acceptance criteria → technical design)
- **Backlog grooming**, sprint planning, and bug tracking are supported
- Claude Code **skills** power the key workflows (`/spec`, `/decompose`, `/groom`, `/sprint`, `/bug`)

### Three Proposals at a Glance

| | System 1: Bespoke | System 2: Plane.so | System 3: GitHub |
|---|---|---|---|
| **One-liner** | Build a custom Supabase web app | Use Plane.so (open-source PM) + MCP | GitHub Projects + `gh` CLI + skills |
| **UI Quality** | B+ (you build it) | **A** (polished, modern) | B- (functional, basic) |
| **Agent Integration** | **A+** (designed for it) | A- (native MCP server) | **A+** (`gh` is native) |
| **Time to Value** | D+ (weeks) | **A** (afternoon) | **A+** (15 minutes) |
| **Portfolio Value** | **A+** | B | B+ |
| **Risk** | High | Low | Very Low |

### Existing Assets

The exocortex repo already has a mature `planning-assistant` skill with Fibonacci sizing, Kanban states (todo/in-progress/done/blocked), sprint cycles, SVG dashboards, and 7 markdown templates. This skill is file-based and has no external integrations — but its patterns, templates, and sizing rubrics can be reused in any of the three systems.

**Key file**: `exocortex/.claude/skills/planning-assistant/SKILL.md`

---

## Three System Proposals

### System 1: "The Bespoke Workshop"

**Build a custom web app from scratch — the PM tool itself becomes a portfolio piece.**

| Attribute | Detail |
|-----------|--------|
| **Stack** | Supabase (PostgreSQL + Auth + Realtime) + Next.js + Tailwind + shadcn/ui |
| **Agent Interface** | Custom MCP server exposing CRUD + spec + board operations |
| **Specs** | Stored in-app with structured editor (problem/solution/AC/tech design) |
| **Board** | Custom Kanban with drag-and-drop, real-time updates via Supabase Realtime |
| **Analytics** | Custom velocity charts, burn-down, cycle time |

**Why choose this:** Maximum portfolio impact. You demonstrate full-stack development, MCP server design, real-time subscriptions, and agentic workflow architecture. The tool is designed from the ground up for one developer working with an AI agent — no feature bloat, no adapting to someone else's data model.

**Why not:** 2-3 weeks of building before it's usable. Real risk of yak-shaving — building the PM tool instead of the data platform. Two projects to maintain.

---

### System 2: "The Augmented Platform"

**Use Plane.so as the PM backbone. Build the agentic layer on top with skills and MCP.**

| Attribute | Detail |
|-----------|--------|
| **Stack** | Plane.so (cloud free tier or self-hosted Docker) + Claude Code skills |
| **Agent Interface** | Plane's native MCP server + custom skills wrapping the API |
| **Specs** | Markdown in `docs/specs/` with front matter linking to Plane issue IDs |
| **Board** | Plane's built-in Kanban (swimlanes, filters, grouping, custom properties) |
| **Analytics** | Plane's built-in cycles burn-down, velocity, analytics dashboard |

**Why choose this:** Best UI without building it. Plane is an open-source Linear/Jira competitor with a polished interface, built-in burn-down charts, and a native MCP server for agent integration. You get a professional-grade PM tool for free and focus your build effort on the agentic skills layer — the part that actually differentiates your workflow.

**Why not:** You're adapting to Plane's data model, not your own. External dependency. Less portfolio "wow factor" than a custom build. Cloud free tier has usage limits (generous, but limits exist).

---

### System 3: "The Lean Machine"

**Stay in GitHub. Projects for the board, Issues for tracking, `gh` CLI for the agent.**

| Attribute | Detail |
|-----------|--------|
| **Stack** | GitHub Projects V2 + GitHub Issues + `gh` CLI + Claude Code skills |
| **Agent Interface** | `gh` CLI (already Claude Code's native tool) |
| **Specs** | Markdown in `docs/specs/` with `Closes #42` cross-references |
| **Board** | GitHub Projects Kanban (custom fields for points, priority, type) |
| **Analytics** | Custom skill logic (no built-in burn-down/velocity) |

**Why choose this:** Zero new dependencies. Zero new accounts. The code lives in GitHub, the tracking lives in GitHub, the PRs and commits link directly to issues on the board. `gh` CLI is what Claude Code already uses — there's zero integration friction. Fastest path to productive use.

**Why not:** GitHub Projects UI is functional but not beautiful. No built-in analytics. Limited board customization. Sprint/velocity tracking requires building it in skills.

---

## Comparative Grading

### UI Design

| Criteria | System 1 | System 2 | System 3 |
|----------|----------|----------|----------|
| Visual polish | B+ (depends on effort) | **A** (professional) | C+ (utilitarian) |
| Kanban board quality | B+ (custom drag-drop) | **A** (swimlanes, filters) | B- (basic columns) |
| Information density | **A** (designed for you) | A- (general-purpose) | B (GitHub layout) |
| Mobile/responsive | B (if you build it) | **A** (built-in) | A- (GitHub is responsive) |
| Customization ceiling | **A+** (unlimited) | B+ (within Plane's model) | C+ (limited fields) |
| **UI Overall** | **B+** | **A** | **B-** |

### Functionality

| Criteria | System 1 | System 2 | System 3 |
|----------|----------|----------|----------|
| Epic/Feature/Story hierarchy | **A+** (custom schema) | A- (sub-issues + modules) | B+ (labels + sub-issues) |
| Backlog management | **A** (custom views) | **A** (built-in) | B (project views) |
| Sprint/cycle planning | **A** (custom) | **A** (cycles + burn-down) | B- (milestones only) |
| Bug tracking | **A** (integrated) | **A** (built-in) | A- (issue labels) |
| Spec writing workflow | **A+** (built-in editor) | B+ (external markdown) | B+ (external markdown) |
| Velocity/analytics | **A** (custom charts) | **A** (built-in analytics) | C (manual tracking) |
| Dependency tracking | A (if you build it) | B+ (basic) | C+ (references only) |
| **Functionality Overall** | **A** | **A-** | **B+** |

### Agentic Integration

| Criteria | System 1 | System 2 | System 3 |
|----------|----------|----------|----------|
| Read board state | **A+** (custom MCP) | A (Plane MCP) | A (`gh project`) |
| Create/update items | **A+** (custom MCP) | A (Plane MCP) | **A+** (`gh issue`) |
| Write specs | **A+** (in-app API) | B+ (file + API link) | B+ (file + issue link) |
| Auto-status updates | **A+** (real-time) | A- (API call) | A (PR auto-close) |
| Agent activity log | **A+** (built-in) | C (no native support) | B- (commit messages) |
| Friction to integrate | B (must build MCP) | A- (MCP exists) | **A+** (gh exists) |
| **Agentic Overall** | **A+** | **A-** | **A+** |

### Practical Considerations

| Criteria | System 1 | System 2 | System 3 |
|----------|----------|----------|----------|
| Time to first productive use | D+ (2-3 weeks) | **A** (1 day) | **A+** (1 hour) |
| Ongoing maintenance | C (two codebases) | A- (updates from Plane) | **A+** (GitHub maintains it) |
| Portfolio/resume value | **A+** (full-stack app) | B (integration work) | B+ (clean GitHub workflow) |
| Risk of scope creep | High | Low | **Very Low** |
| Cost | Free (Supabase free tier) | Free (Plane free tier) | **Free** |

---

## Commercial Landscape

Honest assessment of what's available for free or cheap:

| Tool | Free Tier | Agent-Friendliness | Notes |
|------|-----------|-------------------|-------|
| **Plane.so** | Cloud free (unlimited), self-host option | **Native MCP server**, REST API, webhooks | Best agent integration of any PM tool. Open source. |
| **GitHub Projects** | Free (included with GitHub) | **`gh` CLI** (native to Claude Code) | Already in your workflow. Limited UI. |
| **Linear** | No free tier ($8/user/mo) | Excellent GraphQL API, GitHub sync | Beautiful UI, but costs money. |
| **Taiga** | Open source, self-hosted | REST API | Good Scrum/Kanban, dated UI. |
| **Jira** | Free up to 10 users | REST API, extensive | Heavy. Poor agent ergonomics. |
| **Shortcut** | Free for individuals | REST API | Decent, but small user base. |

**Verdict:** Plane.so is the standout if you want a commercial tool — it's the only PM platform with a native MCP server, and its free tier covers everything a solo developer needs. GitHub Projects is the standout if you want zero dependencies.

---

## Detailed System Designs

### System 1 Detail

#### Data Model (Supabase/PostgreSQL)

```sql
-- Core work item hierarchy
work_items (
  id            uuid PRIMARY KEY,
  type          enum('epic','feature','story','bug','spike'),
  title         text NOT NULL,
  description   text,
  status        enum('backlog','ready','in_progress','in_review','done','blocked'),
  points        int,                    -- Fibonacci: 1,2,3,5,8,13
  priority      enum('critical','high','medium','low'),
  parent_id     uuid REFERENCES work_items(id),  -- Epic→Feature→Story
  sprint_id     uuid REFERENCES sprints(id),
  created_by    enum('human','agent'),
  assignee      text,
  created_at    timestamptz,
  updated_at    timestamptz
)

-- Structured specifications
specs (
  id                  uuid PRIMARY KEY,
  work_item_id        uuid REFERENCES work_items(id),
  problem             text,           -- What problem does this solve?
  solution            text,           -- How will we solve it?
  acceptance_criteria jsonb,          -- Array of Given/When/Then
  technical_design    text,           -- Implementation approach
  status              enum('draft','review','approved','superseded'),
  version             int DEFAULT 1,
  created_at          timestamptz,
  updated_at          timestamptz
)

-- Sprint/cycle tracking
sprints (
  id                uuid PRIMARY KEY,
  name              text,             -- e.g., "Sprint 3" or "PI-2026-W10"
  goal              text,
  start_date        date,
  end_date          date,
  velocity_planned  int,
  velocity_actual   int,
  status            enum('planning','active','complete')
)

-- Agent activity tracking
activity_log (
  id            uuid PRIMARY KEY,
  work_item_id  uuid REFERENCES work_items(id),
  actor         enum('human','agent'),
  action        text,                 -- 'created', 'moved_to_done', 'wrote_spec', etc.
  details       jsonb,
  session_id    text,                 -- Claude Code session identifier
  created_at    timestamptz
)

-- Comments / discussion
comments (
  id            uuid PRIMARY KEY,
  work_item_id  uuid REFERENCES work_items(id),
  author        text,
  body          text,
  created_at    timestamptz
)
```

#### MCP Server Endpoints

```
Tools:
  create_work_item(type, title, description, parent_id?, points?, priority?)
  update_work_item(id, status?, points?, sprint_id?, ...)
  get_work_item(id) → full item with spec, comments, activity
  list_work_items(filters: {type?, status?, sprint_id?, parent_id?})

  write_spec(work_item_id, problem, solution, acceptance_criteria, technical_design)
  update_spec(spec_id, fields...)
  approve_spec(spec_id)

  get_board() → all items grouped by status (Kanban view data)
  get_sprint(id?) → current sprint with committed items and velocity
  get_backlog() → unassigned items sorted by priority

  log_activity(work_item_id, action, details)
  add_comment(work_item_id, body)
```

#### Frontend Pages

1. **Kanban Board** — Drag-and-drop columns (Backlog | Ready | In Progress | In Review | Done | Blocked). Cards show type icon, title, points badge, priority indicator.
2. **Backlog** — Table view with sorting/filtering. Bulk actions for sprint assignment.
3. **Spec Editor** — Structured form (problem/solution/AC/tech design) with markdown preview. Version history sidebar.
4. **Sprint View** — Committed items, velocity gauge, burn-down chart (computed from activity_log timestamps).
5. **Activity Feed** — Chronological log of all agent and human actions. Filter by session.

#### Build Estimate

| Component | Effort |
|-----------|--------|
| Supabase schema + RLS policies | 2-3 hours |
| MCP server (Node.js) | 1-2 days |
| Kanban board UI | 2-3 days |
| Spec editor | 1 day |
| Backlog + Sprint views | 1-2 days |
| Activity feed | Half day |
| Skills (`/spec`, `/decompose`, etc.) | 1-2 days |
| **Total** | **~2 weeks** |

---

### System 2 Detail

#### Setup

1. Create free Plane.so cloud account (or `docker compose up` for self-hosted)
2. Create workspace → project for healthcare-data-platform
3. Configure custom properties:
   - `Type`: Epic, Feature, Story, Bug, Spike
   - `Points`: 1, 2, 3, 5, 8, 13
   - `Layer`: Bronze, Silver, Gold, Platinum
4. Set up Cycles (sprints) with start/end dates
5. Configure Plane's MCP server for Claude Code

#### MCP Integration (Plane Native)

Plane's MCP server provides:
- Issue CRUD (create, read, update, delete)
- Cycle management (create cycle, add issues to cycle)
- Module management (group issues across cycles)
- Label and property management
- State management (custom Kanban columns)

Additional custom skills wrap these MCP calls with domain-specific logic:
- `/spec` → writes markdown spec file + creates Plane issue with link
- `/decompose` → creates sub-issues in Plane with parent linkage
- `/groom` → fetches backlog from Plane, applies sizing rubric, suggests re-ordering

#### Spec Workflow (Hybrid: Repo + Plane)

```
docs/specs/
  story-042-patient-hub.md      # Full spec (problem, solution, AC, tech design)
  story-043-encounter-link.md   # Linked to Plane issue via front matter
```

Front matter:
```yaml
---
plane_issue_id: abc-123
plane_url: https://app.plane.so/workspace/project/issues/abc-123
type: story
feature: Silver Layer Foundation
points: 5
status: approved
---
```

#### What You Don't Build

- Kanban board UI (Plane provides it)
- Burn-down charts (Plane provides them)
- User authentication (Plane handles it)
- Real-time updates (Plane handles it)
- Issue CRUD API (Plane's MCP server handles it)

#### What You Build

| Component | Effort |
|-----------|--------|
| Plane setup + configuration | 1-2 hours |
| MCP server connection + testing | 1-2 hours |
| `/spec` skill | Half day |
| `/decompose` skill | Half day |
| `/groom` skill | Half day |
| `/sprint` skill | Half day |
| `/bug` skill | 1-2 hours |
| `/standup` skill | 1-2 hours |
| **Total** | **~2-3 days** |

---

### System 3 Detail

#### GitHub Projects Setup

1. Create project board: `gh project create --owner danbrickey --title "Healthcare Data Platform"`
2. Add custom fields:

```bash
# Custom fields
gh project field-create <PROJECT_ID> --owner danbrickey \
  --name "Type" --data-type "SINGLE_SELECT" \
  --single-select-options "Epic,Feature,Story,Bug,Spike"

gh project field-create <PROJECT_ID> --owner danbrickey \
  --name "Points" --data-type "SINGLE_SELECT" \
  --single-select-options "1,2,3,5,8,13"

gh project field-create <PROJECT_ID> --owner danbrickey \
  --name "Priority" --data-type "SINGLE_SELECT" \
  --single-select-options "Critical,High,Medium,Low"

gh project field-create <PROJECT_ID> --owner danbrickey \
  --name "Layer" --data-type "SINGLE_SELECT" \
  --single-select-options "Bronze,Silver,Gold,Platinum,Infrastructure"
```

3. Configure board views:
   - **Kanban** — Group by Status, filter by sprint milestone
   - **Backlog** — Table view sorted by Priority then Points
   - **Roadmap** — Timeline view by milestone

#### Issue Templates

```markdown
<!-- .github/ISSUE_TEMPLATE/story.md -->
---
name: Story
about: A user story for implementation
labels: story
---

## User Story
**As a** [role]
**I want** [capability]
**So that** [benefit]

## Acceptance Criteria
- [ ] Given... When... Then...

## Technical Notes
<!-- Implementation approach, dependencies, risks -->

## Points
<!-- Fibonacci: 1, 2, 3, 5, 8, 13 -->
```

#### Hierarchy via Labels + Milestones

```
Labels:
  type: epic, type: feature, type: story, type: bug, type: spike
  layer: bronze, layer: silver, layer: gold, layer: platinum
  priority: critical, priority: high, priority: medium, priority: low
  status: blocked

Milestones:
  Sprint 1 (2026-03-03 → 2026-03-09)
  Sprint 2 (2026-03-10 → 2026-03-16)
  ...

Parent-child: GitHub sub-issues (native feature) or "Part of #XX" references
```

#### Agent Workflow via `gh` CLI

```bash
# Create a story
gh issue create \
  --repo danbrickey/healthcare-data-platform \
  --title "Build patient hub model (h_patient)" \
  --label "type: story,layer: silver,priority: high" \
  --milestone "Sprint 1" \
  --body "## User Story\n..."

# Add to project board
gh project item-add <PROJECT_ID> --owner danbrickey --url <ISSUE_URL>

# Set custom fields
gh project item-edit --project-id <ID> --id <ITEM_ID> \
  --field-id <POINTS_FIELD> --single-select-option-id <5_OPTION>

# Move to "In Progress"
gh project item-edit --project-id <ID> --id <ITEM_ID> \
  --field-id <STATUS_FIELD> --single-select-option-id <IN_PROGRESS>

# Close when done
gh issue close 42 --repo danbrickey/healthcare-data-platform
```

#### What You Build

| Component | Effort |
|-----------|--------|
| GitHub Project board setup + fields | 30 minutes |
| Issue templates (story, bug, epic, feature) | 30 minutes |
| Label taxonomy | 15 minutes |
| `/spec` skill | Half day |
| `/decompose` skill | Half day |
| `/groom` skill | Half day |
| `/sprint` skill | Half day |
| `/bug` skill | 1-2 hours |
| `/standup` skill | 1-2 hours |
| **Total** | **~2-3 days** (mostly skills) |

---

## Skills Layer

These skills are **common to all three systems** — the board/tracking tool is the visualization layer, but the skills are the intellectual property that makes the workflow agentic.

### `/spec` — Structured Spec Writer

**Trigger**: "write a spec for...", "spec this out", "I need to build..."
**Process**:
1. Agent interviews for context (or infers from conversation)
2. Generates structured spec: Problem → Solution → Acceptance Criteria (Given/When/Then) → Technical Design
3. Creates work item in tracking system (Supabase/Plane/GitHub)
4. Writes spec markdown to `docs/specs/` (for Systems 2 & 3)
5. Links spec to work item

### `/decompose` — Epic/Feature Decomposer

**Trigger**: "break this down", "decompose this epic", "what stories do we need?"
**Process**:
1. Reads epic/feature description and spec
2. Proposes logical decomposition into sub-items
3. Applies Fibonacci sizing rubric (reuse from planning-assistant)
4. Creates child items in tracking system
5. Links parent ↔ children bidirectionally

### `/groom` — Backlog Groomer

**Trigger**: "review the backlog", "what should we work on next?", "prioritize"
**Process**:
1. Fetches all backlog items from tracking system
2. Evaluates: stale items, missing estimates, blocked items, dependency conflicts
3. Suggests re-prioritization based on value, dependencies, and sprint capacity
4. Proposes items for next sprint

### `/sprint` — Sprint Planner

**Trigger**: "start a new sprint", "plan the sprint", "what's in this sprint?"
**Process**:
1. Creates sprint/cycle/milestone in tracking system
2. Pulls top-priority items from backlog
3. Checks capacity (target velocity based on history)
4. Commits items to sprint
5. Summarizes sprint goal and committed work

### `/bug` — Quick Bug Reporter

**Trigger**: "found a bug", "this is broken", "`dbt run` failed"
**Process**:
1. Captures: what happened, expected behavior, reproduction steps, error output
2. Creates bug item with appropriate priority
3. Links to related story/feature if applicable
4. Adds to board in "Ready" column

### `/standup` — Session Summary

**Trigger**: End of session, "what did we do?", "standup"
**Process**:
1. Summarizes items touched this session (created, moved, completed)
2. Lists open blockers
3. Suggests next session's focus
4. Updates activity log

---

## Recommended Path Forward

**Decision: Phased hybrid approach.**

1. **Phase 1 (Now)**: System 3 — GitHub board + first skills. Start building the data platform immediately.
2. **Phase 2 (Weeks 2-4)**: Build the data platform. Refine skills based on real usage.
3. **Phase 3 (Week 5+)**: Decide if System 1 (custom app) or System 2 (Plane.so) is worth graduating to, informed by real workflow data.

---

## Verification Plan

Once the system is set up, verify end-to-end:

1. **Setup**: Configure GitHub Projects board with custom fields and views
2. **Seed**: Create 2-3 epics from the existing Phase Zero plan as test data
3. **Spec test**: Use `/spec` to write a real spec for the patient hub model
4. **Decompose test**: Use `/decompose` to break a feature into stories
5. **Workflow test**: Complete one story end-to-end (spec → code → test → done → board updates)
6. **Standup test**: Run `/standup` and verify it accurately summarizes the session
7. **Grooming test**: Run `/groom` on a backlog of 5+ items and verify suggestions are sensible

---

## Critical Files Reference

| File | Relevance |
|------|-----------|
| `docs/planning/phase_00/_plan.md` | Existing planning format to migrate |
| `SPECIFICATION.md` | Source of epics/features to seed the system |
| `exocortex/.claude/skills/planning-assistant/SKILL.md` | Existing planning skill — reuse patterns |
| `exocortex/.claude/skills/planning-assistant/config.yaml` | Configuration patterns to follow |
| `exocortex/.claude/skills/planning-assistant/rubrics/sizing-guide.md` | Fibonacci rubric to reuse |
| `exocortex/.claude/skills/planning-assistant/templates/` | 7 templates (epic, feature, story, etc.) |
| `exocortex/global-skills/` | Skill distribution pattern (junction points) |
