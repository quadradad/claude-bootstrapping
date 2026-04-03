---
name: shipit
user_invocable: true
description: >
  End-to-end autonomous delivery pipeline for a single Claude Code instance — from plan or spec to
  merged, deployed, and verified code. Use this skill whenever the user says "ship it", "build this",
  "execute this plan", "implement this spec", "run the whole thing", "take it from here", "/shipit",
  or any variation of "here's what I want, go make it happen." This skill handles the full lifecycle:
  decomposing work into GitHub issues, building dependency chains, implementing sequentially, running
  tests, doing self-review, committing, pushing, creating PRs, merging, git cleanup, deployment
  verification, and updating documentation — all within a single Claude Code session using a
  continuous execution loop with persistent state. Use it even if the user doesn't mention all these
  steps — the intent is "I have a plan or set of tasks and I want autonomous delivery to completion."
  Works across any project by reading project context at runtime.
---

# /shipit — Solo Autonomous Delivery Pipeline

You are running a full delivery cycle as a single Claude Code agent. The user has handed you a plan,
spec, or set of work items and expects you to take it from intent to production — autonomously,
thoroughly, and cleanly.

Unlike a multi-worker orchestrator, you do everything yourself: decompose, implement, test, review,
merge, clean up, deploy, verify, and document. You maintain state throughout via a dispatch plan file
and GitHub issues, processing the entire backlog in a continuous loop.

Your mindset: you are a senior engineer who also owns the project management. You write production
code, you write tests, you review your own work against a rigorous checklist, and you don't cut
corners. Every issue gets the same discipline whether it's the first or the last.


## The Execution Loop

The core of this skill is a stateful loop. After planning (Phases 0–2), you enter the Implementation
Loop (Phase 3) and process each issue sequentially:

```
Phase 0: Orient → Phase 1: Decompose → Phase 2: Plan
                                          ↓
                              ┌─── Phase 3: Implementation Loop ───┐
                              │                                     │
                              │  For each issue in dependency order: │
                              │    1. Create feature branch          │
                              │    2. Implement + write tests        │
                              │    3. Run tests (fix until green)    │
                              │    4. Self-review checklist          │
                              │    5. Commit + push + create PR      │
                              │    6. Merge PR (squash)              │
                              │    7. Update dispatch plan state     │
                              │    8. Rebase next branch if needed   │
                              │                                     │
                              │  → Next issue (or break if blocked)  │
                              └─────────────────────────────────────┘
                                          ↓
              Phase 4: Integration Test → Phase 5: Clean Up →
              Phase 6: Deploy & Verify → Phase 7: Document → Phase 8: Report
```

The dispatch plan file is your checkpoint. If you need to re-read context mid-run, it tells you
exactly where you are, what's done, and what's next.


## Phase 0: Discover Project Context & Orient

This skill is project-agnostic. Before doing anything, learn the current project's specifics.

### Runtime discovery
Read these sources to build your project context:

1. **CLAUDE.md** — the repo's CLAUDE.md contains the working branch, service names, ports,
   database credentials, build commands, test commands, and operational details. This is your
   primary source of truth.
2. **MEMORY.md** — check for infrastructure references, conventions, and prior feedback.
3. **Docs directory** — if the project has a specs/, docs/, or vault/ directory, scan for
   buildspecs, existing plans, and architectural context.

From these sources, extract and confirm:
- **Working branch** — the active development branch (e.g., `develop`, `main`, `release/v0.1`)
- **Build command** — how to build the project (e.g., `npm run build`, `go build ./...`, `cargo build`)
- **Test command** — how to run tests (e.g., `npm test`, `pytest`, `go test ./...`)
- **Lint command** — if applicable (e.g., `npm run lint`, `golangci-lint run`)
- **Services** — what to restart after deploy (systemd, Docker, PM2, etc.)
- **Database** — connection details and how to verify connectivity
- **Smoke test targets** — endpoints, health checks, or connectivity probes
- **GitHub repo** — org/repo for issue and PR management

If any critical detail is missing, ask one targeted question. Don't guess infrastructure details.

### Detect input type

**Option A — Plan or spec document:** A markdown doc, inline description, or spec of what to build.
Decompose it into discrete tasks (Phase 1).

**Option B — Existing GitHub issues:** An epic, milestone, or set of issues already created.
Skip decomposition; proceed to dependency analysis (Phase 2).

**Option C — Ambiguous:** Ask one clarifying question:
"I see X and Y — should I treat this as [A] or [B]?"

### Orientation checks
Run these to understand current state:
```bash
git status && git log --oneline -5
gh issue list --state open --limit 20
gh pr list --state open
```

If the repo has uncommitted changes or open PRs from prior work, flag it and resolve before
proceeding. Start clean.


## Phase 1: Decompose & Create GitHub Issues

Break the plan into the smallest units of work that can be independently implemented, tested,
and merged.

### Issue anatomy
Every issue follows the project's issue conventions (see `agent_docs/issue-conventions.md`).
Additionally, each issue includes:

- **Test requirements** — what tests to write or update (unit, integration, or both). Tests are
  part of the implementing issue, not a separate issue.
- **Dependencies** — which issues must merge first (use `- Blocked by: #NN — reason` in the body)
- **Scope boundary** — what this issue does NOT cover (keeps you focused during implementation)

### Issue ordering principles
- Group by dependency chain, not by component
- Infrastructure/schema changes come first — they unblock everything else
- Documentation is its own final issue (see Phase 7)
- For 8+ issues: create a GitHub tracking epic with checkbox child issues

### Labels
Apply labels consistently: `enhancement`, `bug`, `refactor`, `docs`, `testing` as appropriate.

### Create issues
```bash
gh issue create --title "..." --body "..." --label "..."
```
Capture all issue numbers. You'll need them for the dispatch plan.


## Phase 2: Build the Dispatch Plan

Before writing any code, create a clear execution plan:

1. **Dependency graph** — which issues are independent vs. which have sequential dependencies
2. **Execution order** — topological sort of the dependency graph; independent issues ordered by
   risk (hardest/riskiest first — if something's going to break the plan, find out early)
3. **Complexity flags** — anything that looks tricky gets extra scrutiny at self-review
4. **Integration test checkpoints** — after which merges should you run the full test suite
   (at minimum: after the last implementation issue, before documentation)

### Write the dispatch plan
Save this to the project's docs directory (e.g., `docs/plans/shipit-<date>-<slug>.md`):

```markdown
# Dispatch Plan: <slug>
Date: <date>
Spec: <link or reference to source plan>
Working branch: <branch>

## Issues (execution order)
| # | Order | Title | Depends On | Status | Branch | PR |
|---|-------|-------|------------|--------|--------|----|
| 42 | 1 | Add user auth middleware | — | pending | | |
| 43 | 2 | Create user profile endpoints | #42 | pending | | |
| 44 | 3 | Add profile validation tests | #42 | pending | | |
| 45 | 4 | Update API documentation | #43, #44 | pending | | |

## Integration checkpoints
- After #44: run full test suite
- After #45: run full test suite + smoke tests

## Notes
<any complexity flags, risk notes, or architectural decisions>
```

This file is your state. Update the Status, Branch, and PR columns as you work through each issue.
If your context gets long or you lose track, re-read this file — it's the source of truth for
pipeline progress.

### Branch naming
Use: `<issue-number>-<short-description>` (e.g., `42-auth-middleware`)


## Phase 3: The Implementation Loop

This is where the work happens. Process each issue in dependency order, one at a time.

### For each issue:

#### Step 1: Create the feature branch
```bash
git checkout <working-branch>
git pull origin <working-branch>
git checkout -b <issue-number>-<slug>
```

#### Step 2: Implement
- Read the issue body for acceptance criteria and scope boundary
- Write the implementation code
- Write tests alongside the implementation (not after)
- Respect the scope boundary — if you discover adjacent work that's needed, note it but don't
  expand scope unless it's blocking. Create a new issue for discovered work if needed.

#### Step 3: Run tests and lint
```bash
<test-command>    # Must pass — fix failures before proceeding
<lint-command>    # Must pass — fix issues before proceeding
<build-command>   # Must compile/build cleanly
```
If tests fail, fix them. If a test failure reveals a deeper issue outside this issue's scope,
stop and reassess — don't chase bugs across issue boundaries.

#### Step 4: Self-review checklist
Before committing, review your own work against this checklist. Be honest — you're the only
reviewer, so rigor here is what prevents bugs from shipping.

**Correctness:**
- [ ] All acceptance criteria from the issue are met
- [ ] Tests exist for new behavior and edge cases
- [ ] Tests actually test the right thing (not just "test exists")
- [ ] No hardcoded values that should be configurable
- [ ] Error handling is present and meaningful (not swallowed errors)

**Safety:**
- [ ] No changes outside the issue's stated scope boundary
- [ ] No modifications to shared interfaces/schemas not specified in the issue
- [ ] No database migrations or data-affecting changes not specified in the issue
- [ ] No secrets, credentials, or PII in the diff

**Quality:**
- [ ] No obvious performance issues (N+1 queries, unbounded loops, missing indexes)
- [ ] No broken imports or dead code introduced
- [ ] Naming is clear and consistent with project conventions
- [ ] Code follows the project's established patterns (check CLAUDE.md conventions)

**If any check fails:** fix it before proceeding. Don't convince yourself it's fine — fix it.

#### Step 5: Commit, push, create PR
```bash
git add <files-changed>
git commit -m "<type>(scope): <description>

Closes #<issue-number>"

git push -u origin <issue-number>-<slug>

gh pr create \
  --title "<issue-title>" \
  --body "Closes #<issue-number>

## Changes
<brief summary of what changed and why>

## Test plan
<how the changes were tested>

## Self-review
All checklist items passed." \
  --base <working-branch>
```

Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:` as appropriate.

#### Step 6: Merge the PR
```bash
gh pr merge <pr-number> --squash --delete-branch
```
Squash merges keep the working branch history clean.

#### Step 7: Update dispatch plan state
Update the dispatch plan file:
- Set this issue's status to `done`
- Fill in the Branch and PR columns
- Check: is the next issue's dependency satisfied? If yes, continue. If not, something is wrong.

#### Step 8: Prepare for next issue
```bash
git checkout <working-branch>
git pull origin <working-branch>
```

If you hit an integration checkpoint (defined in Phase 2), run the full test suite now before
continuing to the next issue. If tests fail, diagnose and fix before moving on — don't
accumulate broken state.

### Loop control
- **Continue** if the next issue's dependencies are all merged and tests are green
- **Stop and report** if: tests are failing post-merge, a dependency is unexpectedly broken,
  or you've discovered that the plan needs revision (e.g., missing issue, wrong dependency order)
- **Escalate to user** if: you encounter spec ambiguity that could lead to significant rework,
  data loss risk, or an architectural decision not covered by the spec


## Phase 4: Full Integration Test

After all implementation issues are merged (documentation issue may still be open):

```bash
git checkout <working-branch>
git pull origin <working-branch>
<build-command>
<test-command>
<lint-command>
```

All three must pass. If anything fails:
1. Diagnose the failure
2. Create a fix on a new branch (`fix-integration-<description>`)
3. PR, self-review, merge — same discipline as any other issue
4. Re-run the full suite until green

Do not proceed to deployment with failing tests.

### E2E tests
If the project has end-to-end tests (Playwright, Cypress, API integration suites, etc.),
run them now:
```bash
<e2e-test-command>
```
E2E failures are serious — they indicate user-facing breakage. Fix before proceeding.


## Phase 5: Clean Up

### Git cleanup
```bash
# Prune remote tracking branches that were deleted by squash merges
git fetch --prune

# Delete any lingering local feature branches from this run
# (use the issue numbers from the dispatch plan)
git branch | grep -E "^  [0-9]+-" | xargs -r git branch -D

# Verify clean state
git status                     # should be clean, on working branch
```

### Close the tracking epic
If an epic issue was created, close it with a summary comment listing all merged PRs:
```bash
gh issue comment <epic-number> --body "All issues delivered. PRs: #X, #Y, #Z"
gh issue close <epic-number>
```


## Phase 6: Deploy & Verify

Code is merged and tests are green — confirm it works in the running system.

### Restart services
Restart all services identified in Phase 0. Wait for startup, then verify they report healthy
status.

### Smoke test sequence
Run in order — stop and diagnose if any step fails:

1. **Service health** — all project services running with clean startup
2. **Log check** — no ERROR or PANIC in recent logs after restart
3. **Database connectivity** — verify the application can reach its database
4. **Message bus / IPC** — if applicable (NATS, Redis, Kafka, etc.), verify connections
5. **API / Frontend** — if applicable, verify key endpoints respond with expected status codes

The specific commands come from project context discovered in Phase 0.

### Rollback
If smoke tests fail and the fix isn't obvious within 5 minutes:
```bash
git revert <merge-commit> --no-edit && git push
# Restart services again
```
Report the failure with full error details and logs. Ship the fix in the next cycle, not as a
hot-patch under pressure.


## Phase 7: Document

Documentation is a deliverable, not an afterthought. This runs as the final issue in the set.

### What to document

1. **Read the original spec or plan** that triggered this `/shipit`
2. **Read the diffs of all merged PRs** — understand exactly what changed:
   ```bash
   gh pr view <N> --json additions,deletions,files
   # or for full diff:
   gh pr diff <N>
   ```
3. **Find affected docs** — search the project's docs for references to changed modules, APIs,
   tables, or flows
4. **Update affected docs** — don't just document the new work; update any existing docs that
   are now stale:
   - Architecture docs or buildspecs for modified components
   - API docs if endpoints changed
   - Operational runbooks if service behavior changed
   - README or onboarding docs if setup steps changed
   - Any notes that reference affected modules, tables, or flows
5. **Create new docs only if needed** — only for genuinely new concepts with no existing doc home
6. **Update the spec's status** — mark it as delivered with date and link to the tracking epic

The goal: zero stale references after this phase.

### Implement as an issue
This follows the same loop discipline as any implementation issue: branch, implement, test (verify
docs build if applicable), self-review, commit, PR, merge.


## Phase 8: Report

Post a concise completion report:

- **Issues delivered** — list with links
- **PRs merged** — list with links
- **Services restarted** — which ones, current status
- **Smoke test results** — all-pass or concerns
- **Integration test results** — full suite status
- **Duration** — how long the pipeline took
- **Notable decisions** — anything decided autonomously that the user should know
- **Docs updated** — which files were created or modified
- **Discovered work** — any new issues created for out-of-scope items found during implementation

Keep it tight — the user can dig into PRs and issues for details.


## Scope & Escalation Guidelines

Since you're both implementer and reviewer, discipline around scope is critical.

**Handle autonomously:** implementation decisions within issue scope, test strategy, commit
structure, reasonable refactoring of code you're touching, minor adjacent fixes that are clearly
safe (fixing a typo in a neighboring line).

**Stop and create a new issue (don't expand scope):** changes to shared interfaces or schemas
not in the current issue, work outside the stated scope boundary, database migrations not
specified, anything that would change the dependency graph.

**Escalate to user:** unexpected architectural decisions, data loss risk, service-affecting
choices not covered by the spec, ambiguity that could lead to significant rework if guessed wrong.


## Error Handling

- **Fail fast, fail loud.** Stop and report rather than pushing broken code hoping the next step
  fixes it.
- **Tests are the gate.** Never merge with failing tests. Never skip tests to save time.
- **The dispatch plan is your state.** If you lose track, re-read it. If context is getting long,
  re-read it. It tells you exactly where you are.
- **Rollback is always an option.** Don't spend more than 5 minutes debugging a post-deploy
  failure before reverting. Ship the fix in the next cycle.
- **Preserve evidence.** Capture error output, test failures, and logs before moving on. Include
  them in issue comments so there's a record.
- **Scope boundaries prevent cascading problems.** They exist so that a mistake in one issue
  doesn't silently break everything downstream. Respect them.
