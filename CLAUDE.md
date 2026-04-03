# Project Configuration

> This file defines how Claude operates in this project. The baseline sections are universal.
> Project-specific sections are appended below the bootstrap marker by `/bootstrap-claude`.

## Development Philosophy

- **Test-Driven Development (TDD):** Always write tests before implementation.
  1. Write test file first with test cases for happy path and key error cases
  2. Run tests — confirm new tests fail (red)
  3. Implement the production code
  4. Run tests — confirm all tests pass (green)
  5. Refactor if needed
- **Issue-Driven Workflow:** All work is tracked via the project's task tracker. Default: external issue tracker (see Issue Tracker section). Can be configured to use `tasks/todo.md` via `/bootstrap-claude`.
- **Validate Before Claiming Completion:** Always run the project's validation command before committing, closing issues, or claiming work is done. Never skip validation.
- **YAGNI:** Don't over-engineer. Only build what's needed now. Three similar lines of code is better than a premature abstraction.
- **DRY within reason:** Avoid duplication, but don't create abstractions for one-time operations.
- **Plan Before Building:** Enter plan mode for any task with 3+ steps or that involves architectural decisions. Write detailed specs upfront. If implementation hits unexpected complexity or repeated failures, stop and re-plan rather than pushing through.
- **Challenge Your Work:** For non-trivial changes, pause and ask "is there a more elegant way?" before presenting. Skip for simple, obvious fixes. This is about implementation quality within scope, not scope expansion.
- **Fix Bugs Autonomously:** When given a bug report with logs, errors, or failing tests, diagnose and resolve directly. Don't ask for hand-holding — read the evidence and fix it. Zero context switches required from the user.

## Subagent Strategy

- Use subagents to keep the main context window clean
- Offload research, exploration, and parallel analysis to subagents
- One focused task per subagent — don't overload
- For complex problems, use multiple subagents rather than serial deep-dives
- Subagent results feed back into the main thread as summarized findings

## Session Start

At the beginning of a fresh session on an existing project:
1. Review `.claude/lessons.md` for patterns relevant to the current work
2. Assess current state: run `/triage` or check the task tracking file
3. Decide next action: continue interrupted work, pick up the next unblocked task, or plan new work

## Continuous Improvement

Maintain `.claude/lessons.md` with patterns learned from corrections and reviews.

**When to update:**
- After ANY user correction — capture what went wrong and the better approach
- After `/review-pr` finds issues you introduced — reflect on why (see /review-pr § Self-Improvement)
- Ruthlessly deduplicate — update existing entries rather than adding redundant ones

**Format:**
### [Pattern name]
- **Wrong:** [what was done incorrectly]
- **Right:** [the correct approach]
- **Why:** [root cause or reasoning]

## Issue Management

All work is tracked via the project's task tracker with structured metadata.

**Issue format:**
```
Title: {type}({scope}): {description}

Types: feat | fix | refactor | docs | discovery | design | infra
Scopes: defined per-project (see Project-Specific Configuration below)
```

**Issue body structure:**
```
## Summary
[1-3 sentences describing what and why]

## Dependencies
- Blocked by: #NN — [reason]
- Part of: #EPIC — [epic title]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]
- [ ] Validation passes

## Implementation Notes
[Key files, approach, constraints]
```

**Dependency format (canonical — the ONLY recognized format):**
```
- Blocked by: #NN — reason
```
`#NN` uses the configured issue reference format (see Issue Tracker section). Other patterns (`depends on`, `waiting on`, `after #NN`) are NOT recognized by automation.

## Issue Tracker

> Configured by `/bootstrap-claude`. Default: GitHub Issues (`gh` CLI).
> To use a different tracker (Jira, Linear, etc.), update this section
> and the corresponding permissions in settings.local.json.

**Tool:** GitHub CLI (`gh`)
**Issue reference format:** `#NN` (e.g., `#53`)
**Smart close syntax:** `Closes #NN`
**Dependency format:** `- Blocked by: #NN — reason`

### Operations Reference

| Operation | Command |
|-----------|---------|
| List open issues | `gh issue list --state open --limit 200 --json number,title,body,labels,milestone,assignees` |
| View issue | `gh issue view NUMBER --json number,title,body,labels,milestone,assignees` |
| View issue body | `gh issue view NUMBER --json body --jq '.body'` |
| Create issue | `gh issue create --title "TITLE" --body "BODY" --label "LABEL" [--assignee "USER"]` |
| Edit issue body | `gh issue edit NUMBER --body "BODY"` |
| Close issue | `gh issue close NUMBER` |
| Comment on issue | `gh issue comment NUMBER --body "COMMENT"` |
| Add label | `gh issue edit NUMBER --add-label "LABEL"` |
| Remove label | `gh issue edit NUMBER --remove-label "LABEL"` |
| Assign to milestone | `gh issue edit NUMBER --milestone "NAME"` |
| Create milestone | `gh api repos/{owner}/{repo}/milestones --method POST -f title="NAME" -f state="open"` |
| List milestones | `gh api repos/{owner}/{repo}/milestones` |
| Check milestone progress | `gh api repos/{owner}/{repo}/milestones/{number}` |
| Resolve current user | `gh api user --jq '.login'` |
| List collaborators | `gh api repos/{owner}/{repo}/collaborators --jq '.[].login'` |

## Commit Conventions

Use conventional commits format:
```
type(scope): description

- Bullet point 1
- Bullet point 2

Closes #NN
```

- Types: `feat`, `fix`, `refactor`, `docs`, `discovery`, `design`, `infra`
- Include the smart close syntax (see Issue Tracker section) to auto-close the linked issue when merged
- List key changes in the body
- Never force-push or rewrite history on shared branches

## PR Workflow

- Every change gets a pull request
- PRs link to issues via the smart close syntax (see Issue Tracker section) in the body
- Feature branches target the release branch (if one exists), otherwise `main`
- Branch naming: `{issue-number}-{slug}` (e.g., `53-add-auth-service`)
- Use `/review-pr` before merging
- One issue per feature branch — don't bundle unrelated work

## Commands & Skills

### Commands (slash commands)

| Command | Purpose |
|---------|---------|
| `/wiggum` | Automated dev loop — pick next unblocked issue, implement, test, close, repeat |
| `/triage` | Analyze backlog — dependency graph, readiness, label validation, prioritization |
| `/create-issues` | Create issues from a plan — with tracking epic, dependencies, assignee resolution |
| `/close-issue` | Validate acceptance criteria and close an issue with structured comment |
| `/review-pr` | Review a PR against project quality standards |
| `/validate-pr` | Validate a release PR — review, post findings, create issues for failures |
| `/setup-release` | Plan a release — milestone, branch, implementation order |
| `/bootstrap-claude` | Adapt Claude configuration to the current project's tech stack and conventions |
| `/update-claude` | Pull golden set updates into a bootstrapped project |
| `/improve-golden-set` | Extract generalized improvements from a project back into the golden set |
| `/slim` | Audit the golden set for bloat and budget compliance — compress or remove content |

### Skills (auto-invoked)

| Skill | Purpose |
|-------|---------|
| `/shipit` | End-to-end autonomous delivery — from plan or spec to merged, deployed, and verified |
| `/grill-me` | Stress-test a plan or design through relentless interview until shared understanding |
| `/pomo` | Post-fix reflection — capture lessons learned and update project memory |
| `/browser-automation` | Browser interaction — navigate, click, fill forms, screenshot, test web UIs |

## Code Quality

- Run the project validation command before every commit
- Follow existing project conventions — don't introduce new patterns without discussion
- No hardcoded values that should be configuration
- Error handling at system boundaries
- No committed credentials, secrets, or .env files
- Tests exist for new functionality

## Pre-existing Failures

If a test file you did NOT modify is failing, the failure is pre-existing. Create an issue for it (if one doesn't already exist) using the **create issue** operation (CLAUDE.md § Issue Tracker) and continue — do not silently work around it.

<!-- bootstrap-claude: project-specific below -->
<!-- Everything below this line is generated by /bootstrap-claude for this specific project -->
<!-- To regenerate: delete everything below this marker and run /bootstrap-claude again -->

## Project Overview

**Project:** Claude Bootstrapping
**Architecture:** Configuration/documentation repository — a portable "golden set" of Claude Code configuration with a deployment script
**Tech Stack:** Bash, Markdown

## How to Build / Test / Run

| Command | Purpose |
|---------|---------|
| `./deploy.sh /path/to/project` | Deploy the golden set into a target project |
| `bash -n deploy.sh` | Syntax-check the deploy script |

**Validation command:** `bash -n deploy.sh` — this is the hard gate for all workflow commands. Note: this project has no compiled code or test suite; validation is limited to shell syntax checking.

## Project Structure

| File/Directory | Purpose |
|---------------|---------|
| `golden/` | The portable golden set — all baseline configuration lives here |
| `golden/CLAUDE.md` | Master baseline CLAUDE.md (universal sections only) |
| `golden/.claude/commands/` | Workflow command definitions (9 commands) |
| `golden/.claude/agents/` | Subagent definitions (code-reviewer) |
| `golden/.claude/settings.local.json` | Baseline pre-approved tool permissions |
| `golden/.mcp.json` | Baseline MCP server config |
| `deploy.sh` | Script to copy golden set into target projects |
| `docs/plans/` | Design documents and implementation plans |
| `images/` | Workflow illustration |

## Issue Scopes

Scopes for commit messages and issue titles:
- `golden`: Changes to the golden set (commands, agents, CLAUDE.md baseline, settings, MCP config)
- `deploy`: Changes to deploy.sh or deployment mechanism
- `docs`: Documentation changes (README, design docs, plans)

## Architecture Rules

- **Golden set is the source of truth.** All portable configuration lives in `golden/`. The root-level CLAUDE.md, .claude/, and .mcp.json are deployed copies — edit `golden/` to make changes, then re-deploy.
- **Commands must be project-agnostic.** Commands in `golden/.claude/commands/` must work for any tech stack. Never hardcode project-specific file paths, framework names, or tool names.
- **Bootstrap marker discipline.** Content above the marker in CLAUDE.md is baseline (universal). Content below is project-specific (generated by /bootstrap-claude). Never mix the two.

## Key Files

| File | Purpose |
|------|---------|
| `golden/CLAUDE.md` | Master baseline — edit this, not root CLAUDE.md |
| `golden/.claude/commands/bootstrap-claude.md` | The project adapter command (562 lines) |
| `golden/.claude/commands/wiggum.md` | Autonomous dev loop |
| `golden/.claude/commands/improve-golden-set.md` | Extract improvements from projects |
| `golden/.claude/commands/update-claude.md` | Pull golden set updates into projects |
| `deploy.sh` | Deployment script |

## Task Tracker

All work is tracked in `tasks/todo.md`.

**Task reference format:** `T-NN` (e.g., `T-1`)
**Commit reference:** `Completes T-NN`
**Dependency format:** `- Blocked by: T-NN — reason`
