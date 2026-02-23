# Golden Set + Bootstrap-Claude Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the dotfiles repo from a backup/restore system into a portable "golden set" of Claude configuration with a self-adapting bootstrap skill.

**Architecture:** A `golden/` directory mirrors a project root (CLAUDE.md, .claude/, .mcp.json). A `deploy.sh` script copies it into any target project. A `/bootstrap-claude` skill inside the golden set then adapts the generic config to the specific project by scanning tech stack, confirming with the user, and appending project-specific config.

**Tech Stack:** Shell scripting (deploy.sh), Claude Code skills/commands/agents (Markdown), JSON config files.

**Reference:** Design doc at `docs/plans/2026-02-23-golden-set-bootstrap-design.md`

---

### Task 1: Create Directory Structure

**Files:**
- Create: `golden/CLAUDE.md` (placeholder)
- Create: `golden/.claude/commands/` (directory)
- Create: `golden/.claude/skills/bootstrap-claude/` (directory)
- Create: `golden/.claude/agents/` (directory)

**Step 1: Create all directories**

```bash
mkdir -p golden/.claude/commands
mkdir -p golden/.claude/skills/bootstrap-claude
mkdir -p golden/.claude/agents
```

**Step 2: Verify structure**

Run: `find golden -type d | sort`
Expected:
```
golden
golden/.claude
golden/.claude/agents
golden/.claude/commands
golden/.claude/skills
golden/.claude/skills/bootstrap-claude
```

**Step 3: Commit**

```bash
git init
git add golden/
git commit -m "chore: scaffold golden set directory structure"
```

---

### Task 2: Create Golden CLAUDE.md

**Files:**
- Create: `golden/CLAUDE.md`

This is the universal baseline — no project-specific language, framework, or file path references. Bootstrap fills those in below the marker.

**Step 1: Write the golden CLAUDE.md**

Write the following to `golden/CLAUDE.md`:

```markdown
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
- **Issue-Driven Workflow:** All work is tracked via GitHub Issues. Never create tracking markdown files in the repository — use Issues, milestones, and project boards instead.
- **Validate Before Claiming Completion:** Always run the project's validation command before committing, closing issues, or claiming work is done. Never skip validation.
- **YAGNI:** Don't over-engineer. Only build what's needed now. Three similar lines of code is better than a premature abstraction.
- **DRY within reason:** Avoid duplication, but don't create abstractions for one-time operations.

## Issue Management

All work is tracked via GitHub Issues with structured metadata.

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
Other patterns (`depends on`, `waiting on`, `after #NN`) are NOT recognized by automation.

## Commit Conventions

Use conventional commits format:
```
type(scope): description

- Bullet point 1
- Bullet point 2

Closes #NN
```

- Types: `feat`, `fix`, `refactor`, `docs`, `discovery`, `design`, `infra`
- Include `Closes #NN` to auto-close the linked issue when merged
- List key changes in the body
- Never force-push or rewrite history on shared branches

## PR Workflow

- Every change gets a pull request
- PRs link to issues via `Closes #NN` in the body
- Feature branches target the release branch (if one exists), otherwise `main`
- Branch naming: `{issue-number}-{slug}` (e.g., `53-add-auth-service`)
- Use `/review-pr` before merging
- One issue per feature branch — don't bundle unrelated work

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/wiggum` | Automated dev loop — pick next unblocked issue, implement, test, close, repeat |
| `/triage` | Analyze backlog — dependency graph, readiness, label validation |
| `/create-issues` | Convert a plan into structured GitHub issues with tracking epic |
| `/close-issue` | Validate acceptance criteria and close an issue with structured comment |
| `/review-pr` | Standardized PR review against project quality standards |
| `/setup-release` | Plan a release — milestone, branch, implementation order |
| `/bootstrap-claude` | Adapt this configuration to the current project's tech stack |

## Code Quality

- Run the project validation command before every commit
- Follow existing project conventions — don't introduce new patterns without discussion
- No hardcoded values that should be configuration
- Error handling at system boundaries
- No committed credentials, secrets, or .env files
- Tests exist for new functionality

## Pre-existing Failures

If a test file you did NOT modify is failing, the failure is pre-existing. Create a GitHub issue for it (if one doesn't already exist) and continue — do not silently work around it.

<!-- bootstrap-claude: project-specific below -->
<!-- Everything below this line is generated by /bootstrap-claude for this specific project -->
<!-- To regenerate: delete everything below this marker and run /bootstrap-claude again -->
```

**Step 2: Verify the file reads correctly**

Run: `wc -l golden/CLAUDE.md`
Expected: approximately 90-100 lines

**Step 3: Commit**

```bash
git add golden/CLAUDE.md
git commit -m "feat: add baseline golden CLAUDE.md

Universal development philosophy, issue management, commit conventions,
PR workflow, and workflow commands. No project-specific content —
bootstrap-claude fills that in."
```

---

### Task 3: Create Golden Commands

**Files:**
- Create: `golden/.claude/commands/wiggum.md`
- Create: `golden/.claude/commands/close-issue.md`
- Create: `golden/.claude/commands/create-issues.md`
- Create: `golden/.claude/commands/review-pr.md`
- Create: `golden/.claude/commands/triage.md`
- Create: `golden/.claude/commands/setup-release.md`

These are genericized versions of the existing commands. Key changes from the project-specific versions:
- Replace all hardcoded validation commands (`npm run validate`, `npm test`, `npm run type-check`) with references to "the project's validation command defined in CLAUDE.md"
- Replace project-specific architecture references (Electron process boundaries, IPC conventions, Go API patterns) with generic references to "architecture rules defined in CLAUDE.md"
- Replace project-specific layer groupings with generic "group by project labels"
- Replace project-specific scope lists with generic reference to CLAUDE.md
- Remove all project-specific file paths

**Step 1: Write wiggum.md**

Write to `golden/.claude/commands/wiggum.md`. This is the automated dev loop. Base it on the git_branch_tracker version (most comprehensive) but genericize all project-specific references.

Key genericizations:
- Step 4 (Understand): Remove references to ERD.md, specific services, component patterns. Replace with "Review relevant existing code and architecture docs referenced in CLAUDE.md"
- Step 5 (Implement): Remove Electron-specific implementation patterns. Replace with "Follow the project's architecture strictly as defined in CLAUDE.md" and keep the TDD sub-steps
- Step 6 (Validate): Replace `npm run validate` with "Run the project's validation command (defined in CLAUDE.md)"
- Step 7 (Docs): Remove project-specific doc mapping table. Replace with "Check if implementation requires documentation updates per the project's documentation conventions"
- Step 8 (Commit): Keep generic conventional commits format
- Rules: Remove project-specific rules (process boundaries, npm scripts). Keep generic rules (TDD, validation gate, no force-push)

**Step 2: Write close-issue.md**

Write to `golden/.claude/commands/close-issue.md`. Genericize:
- Step 2: Replace `npm run validate` with "the project's validation command (from CLAUDE.md)"
- Step 5: Remove project-specific architecture file lists. Replace with "Check if the implementation touched architecture-sensitive files as defined in CLAUDE.md"
- Rules: Replace `npm run validate` references with generic validation command

**Step 3: Write review-pr.md**

Write to `golden/.claude/commands/review-pr.md`. Genericize:
- Title: Remove "Canopy quality standards" → "project quality standards"
- Section 2: Replace "Process Boundary Compliance" with "Architecture Compliance" — "Check the diff against architecture rules defined in CLAUDE.md. Look for violations of layer boundaries, import restrictions, and conventions."
- Section 3: Replace Electron-specific holistic check with generic "If shared types or interfaces changed, verify all consuming layers were updated"
- Section 4: Replace project-specific code quality checks with generic ones (no hardcoded values, error handling, no committed secrets, tests exist)
- Section 6: Replace Electron security checks with generic security checks (no committed credentials, no injection vulnerabilities, validated external inputs)
- Section 7: Replace `npm run validate` with project validation command
- Rules: Keep all generic rules

**Step 4: Write create-issues.md**

Write to `golden/.claude/commands/create-issues.md`. Genericize:
- Step 4 scope list: Replace `main | renderer | shared | db | ui` with "use project-specific scopes defined in CLAUDE.md, or omit for cross-cutting"
- Step 4 acceptance criteria: Replace `npm test` and `npm run type-check` with "Validation passes" (generic)
- Step 4 labels: Replace project-specific labels with "Apply labels based on project conventions in CLAUDE.md"
- Rules: Replace `npm test` and `npm run type-check` references with "Validation passes"

**Step 5: Write triage.md**

Write to `golden/.claude/commands/triage.md`. Genericize:
- Step 5: Remove project-specific label references. Keep generic label consistency checks.
- Step 6: Replace hardcoded layer groupings with "Group by project labels. Use labels and title scopes to categorize. Fall back to: Feature, Bug, Docs, Infrastructure, Discovery/Design, Tracking, Cross-cutting"

**Step 6: Write setup-release.md**

Write to `golden/.claude/commands/setup-release.md`. Genericize:
- Step 1: Replace hardcoded label keyword mappings with "Map keywords to GitHub labels. Common mappings: `bugs`/`bug` → `bug`, `features`/`feat` → `enhancement`, `docs` → `documentation`. For project-specific labels, check CLAUDE.md."
- Step 5: Remove "Canopy" from milestone description. Use generic project name.

**Step 7: Verify all 6 commands exist**

Run: `ls -la golden/.claude/commands/`
Expected: 6 .md files

**Step 8: Commit**

```bash
git add golden/.claude/commands/
git commit -m "feat: add genericized golden commands

Six universal workflow commands (wiggum, close-issue, create-issues,
review-pr, triage, setup-release) genericized from project-specific
versions. All project-specific references replaced with CLAUDE.md
references that bootstrap-claude fills in."
```

---

### Task 4: Create Golden Code Reviewer Agent

**Files:**
- Create: `golden/.claude/agents/code-reviewer.md`

The generic version keeps universal quality checks and references CLAUDE.md for project-specific rules. Bootstrap will append project-specific sections.

**Step 1: Write the golden code-reviewer.md**

Write to `golden/.claude/agents/code-reviewer.md`:

```markdown
# Code Reviewer Agent

Review code changes for project quality standards and architecture compliance.

Consult CLAUDE.md for project-specific architecture rules, layer boundaries, and conventions.

## What to Check

### Architecture Compliance
- Layer boundaries are respected — no imports that cross architecture boundaries defined in CLAUDE.md
- Shared types/interfaces are defined in their designated location, not duplicated across layers
- New abstractions follow the project's established patterns
- No bypassing of the project's data access conventions

### Code Quality
- No unjustified `any` (TypeScript) or equivalent type-safety bypasses
- No hardcoded values that should be configuration or design tokens
- Error handling at system boundaries — human-readable error messages
- No committed credentials, secrets, or .env files
- No over-engineering (YAGNI)

### Test Coverage
- New functionality has tests
- Bug fixes include regression tests
- Test files follow the project's test location conventions
- Tests are meaningful — not just "it doesn't throw"

### Security
- No committed secrets or credentials
- No injection vulnerabilities (SQL injection, command injection, XSS)
- External inputs are validated
- Sensitive data is handled appropriately

### General
- Commit messages follow conventional format
- PR links to an issue
- Documentation updated if architecture changed
- No unnecessary files in the diff (.DS_Store, build artifacts, etc.)

<!-- bootstrap-claude: project-specific checks below -->

## Output Format

```markdown
## Code Review Summary

### Issues Found
- [CRITICAL] ...
- [WARNING] ...

### Architecture Compliance: PASS/FAIL
- ...

### Code Quality: PASS/FAIL
- ...

### Test Coverage: PASS/FAIL
- ...

### Security: PASS/FAIL
- ...

### Suggestions
- ...
```
```

**Step 2: Commit**

```bash
git add golden/.claude/agents/code-reviewer.md
git commit -m "feat: add generic code reviewer agent

Universal review checks for architecture, quality, tests, and security.
Bootstrap-claude appends project-specific checks below the marker."
```

---

### Task 5: Create Golden Settings and MCP Config

**Files:**
- Create: `golden/.claude/settings.local.json`
- Create: `golden/.mcp.json`

**Step 1: Write baseline settings.local.json**

Write to `golden/.claude/settings.local.json`. Include only universal permissions that apply to any project:

```json
{
  "permissions": {
    "allow": [
      "Bash(git fetch:*)",
      "Bash(git push:*)",
      "Bash(git pull:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git merge:*)",
      "Bash(git checkout:*)",
      "Bash(git branch:*)",
      "Bash(git log:*)",
      "Bash(git stash:*)",
      "Bash(git stash push:*)",
      "Bash(git stash pop:*)",
      "Bash(git cherry-pick:*)",
      "Bash(git rebase:*)",
      "Bash(git check-ignore:*)",
      "Bash(git rm:*)",
      "Bash(git mv:*)",
      "Bash(git -C:*)",
      "Bash(git ls-tree:*)",
      "Bash(git diff:*)",
      "Bash(git show:*)",
      "Bash(git tag:*)",
      "Bash(git remote:*)",
      "Bash(gh pr create:*)",
      "Bash(gh pr view:*)",
      "Bash(gh pr list:*)",
      "Bash(gh pr diff:*)",
      "Bash(gh pr comment:*)",
      "Bash(gh pr edit:*)",
      "Bash(gh pr review:*)",
      "Bash(gh pr merge:*)",
      "Bash(gh pr ready:*)",
      "Bash(gh api:*)",
      "Bash(gh repo view:*)",
      "Bash(gh issue create:*)",
      "Bash(gh issue view:*)",
      "Bash(gh issue list:*)",
      "Bash(gh issue edit:*)",
      "Bash(gh issue close:*)",
      "Bash(gh issue comment:*)",
      "Bash(gh label list:*)",
      "Bash(gh label create:*)",
      "Bash(npm install:*)",
      "Bash(npm i:*)",
      "Bash(npm uninstall:*)",
      "Bash(npm test:*)",
      "Bash(npm run:*)",
      "Bash(npm ls:*)",
      "Bash(npm start:*)",
      "Bash(npx:*)",
      "Bash(npx vitest:*)",
      "Bash(npx tsc:*)",
      "Bash(npx eslint:*)",
      "Bash(npx prettier:*)",
      "Bash(node:*)",
      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(pip:*)",
      "Bash(pip3:*)",
      "Bash(make:*)",
      "Bash(ls:*)",
      "Bash(wc:*)",
      "Bash(echo:*)",
      "Bash(ps:*)",
      "Bash(lsof:*)",
      "Bash(open:*)",
      "Bash(chmod:*)",
      "Bash(curl:*)",
      "Bash(source:*)",
      "WebFetch(domain:github.com)",
      "mcp__plugin_playwright_playwright__browser_snapshot",
      "mcp__plugin_playwright_playwright__browser_navigate",
      "mcp__plugin_playwright_playwright__browser_wait_for",
      "mcp__plugin_playwright_playwright__browser_console_messages",
      "mcp__plugin_playwright_playwright__browser_network_requests",
      "mcp__plugin_playwright_playwright__browser_evaluate",
      "mcp__plugin_playwright_playwright__browser_take_screenshot",
      "mcp__plugin_playwright_playwright__browser_hover",
      "mcp__plugin_playwright_playwright__browser_click",
      "mcp__plugin_playwright_playwright__browser_type",
      "mcp__plugin_playwright_playwright__browser_close",
      "mcp__plugin_playwright_playwright__browser_run_code"
    ]
  },
  "enableAllProjectMcpServers": true
}
```

Note: Added `git diff`, `git show`, `git tag`, `git remote`, and `make` which appeared in project-specific configs but are universally useful.

**Step 2: Write baseline .mcp.json**

Write to `golden/.mcp.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

**Step 3: Commit**

```bash
git add golden/.claude/settings.local.json golden/.mcp.json
git commit -m "feat: add baseline permissions and MCP config

Universal permissions for git, gh, npm, node, python, make, playwright.
Context7 MCP server as baseline. Bootstrap-claude adds project-specific
permissions and MCP servers."
```

---

### Task 6: Create Bootstrap-Claude Skill

**Files:**
- Create: `golden/.claude/skills/bootstrap-claude/SKILL.md`

This is the most complex file. It's a skill that scans a project, confirms findings with the user, and adapts the golden set config.

**Step 1: Write the bootstrap-claude skill**

Write to `golden/.claude/skills/bootstrap-claude/SKILL.md`:

```markdown
---
name: bootstrap-claude
description: Scan the current project and adapt Claude configuration to its tech stack, conventions, and structure
user_invocable: true
---

# /bootstrap-claude — Project Configuration Adapter

Scans the current project, builds a profile of its tech stack and conventions, confirms findings with the user, and adapts the golden set Claude configuration to this specific project.

## When to Use

Run this after deploying the golden set into a new project:
```
./deploy.sh /path/to/project
cd /path/to/project
claude
> /bootstrap-claude
```

Can also be re-run to update configuration after significant project changes.

## Phase 1: Discovery

Scan the project to build a comprehensive profile. Check for ALL of the following:

### Tech Stack Detection

| File/Pattern | Indicates |
|-------------|-----------|
| `package.json` | Node.js/JavaScript/TypeScript project |
| `tsconfig.json` | TypeScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python |
| `Gemfile` | Ruby |
| `pom.xml` / `build.gradle` | Java/Kotlin |
| `Makefile` | Make-based build |
| `Dockerfile` / `docker-compose.yml` | Docker |
| `.csproj` / `.sln` | .NET |

### Framework Detection

| File/Pattern | Indicates |
|-------------|-----------|
| `next.config.*` | Next.js |
| `vite.config.*` | Vite |
| `angular.json` | Angular |
| `svelte.config.*` | SvelteKit |
| `nuxt.config.*` | Nuxt |
| `remix.config.*` | Remix |
| `expo-*` in package.json | Expo / React Native |
| `react-native` in package.json | React Native |
| `electron` in package.json / `forge.config.*` | Electron |
| `tailwind.config.*` | Tailwind CSS |
| `flask` / `django` in requirements | Flask/Django |
| `fastapi` in requirements | FastAPI |
| `gin` / `echo` / `fiber` in go.mod | Go web frameworks |
| `actix` / `axum` in Cargo.toml | Rust web frameworks |

### Build/Test Tooling

Detect test runners, linters, formatters, build commands by checking:
- `package.json` scripts (test, lint, build, validate, format, type-check)
- `Makefile` targets (test, lint, build, validate)
- `pyproject.toml` tool configs (pytest, ruff, black, mypy)
- `.eslintrc*`, `.prettierrc*`, `biome.json`
- `jest.config.*`, `vitest.config.*`, `pytest.ini`
- `golangci-lint` config, `.golangci.yml`

**Identify the validation command:** Look for a single command that runs all checks:
- `npm run validate` (if it exists in package.json scripts)
- `make validate` or `make check`
- Fallback: compose from individual commands (test + lint + type-check)

### CI/CD Detection

Check for:
- `.github/workflows/*.yml` — GitHub Actions
- `Jenkinsfile` — Jenkins
- `.gitlab-ci.yml` — GitLab CI
- `.circleci/config.yml` — CircleCI
- `Dockerfile` — containerized deployment

### Documentation Detection

Check for:
- `README.md` at root
- `docs/` directory with markdown files
- `wiki/` directory
- Architecture docs (`ARCHITECTURE.md`, `ERD.md`, `DESIGN.md`)
- API docs (`openapi*.yaml`, `swagger.*`)
- Any `.md` files in the root beyond README

### Project Structure

Identify the primary abstraction and architecture pattern:
- **Monorepo:** `packages/`, `apps/`, `libs/` directories, or workspaces in package.json
- **API + Frontend:** Separate api/ and web/ or frontend/ directories
- **Pipeline:** Multiple sequential processing stages
- **Library:** Single package with src/ and tests/
- **CLI tool:** bin/ or cli/ with argument parsing
- **Desktop app:** Electron, Tauri indicators

### Git State

- Is this a git repo? (`git rev-parse --is-inside-work-tree`)
- Does `.gitignore` exist?
- Are there existing branches? What's the default branch?

### Existing Claude Config

- Does `CLAUDE.md` already have content below the bootstrap marker?
- Are there existing project-specific skills in `.claude/skills/`?
- This indicates a re-bootstrap — warn the user before overwriting.

## Phase 2: Confirm with User

Present the discovery results and ask questions. Use Claude's AskUserQuestion tool for structured choices.

### Question 1: Project Profile

Present the detected profile:

```
## Detected Project Profile

**Tech Stack:** [languages and frameworks detected]
**Build System:** [build tool and key commands]
**Test Runner:** [test framework and command]
**Validation Command:** [detected or composed validation command]
**Linter/Formatter:** [detected tools]
**CI/CD:** [detected system]
**Architecture:** [detected pattern — monorepo, API+frontend, etc.]
**Documentation:** [what was found]

Is this accurate? (Select any corrections needed)
```

Let the user correct anything that's wrong.

### Question 2: Git Integration

Ask: **"Should Claude configuration files be checked into git or gitignored?"**

Options:
- **Check into git** — Team shares Claude config. Good for teams using Claude together.
- **Add to .gitignore** — Personal config, not shared. Good for solo use or mixed teams.

### Question 3: Documentation Scaffold

If no `docs/` directory (or equivalent knowledge base) was detected, ask:

**"I don't see a documentation directory. Should I create one?"**

Options:
- **Yes, create docs/** — Creates a `docs/` directory with a README establishing documentation conventions for future agent sessions.
- **No, skip** — Project doesn't need structured documentation beyond README.

### Question 4: Issue Scopes

Ask: **"What scopes should be used for issue titles and commit messages?"**

Suggest scopes based on detected architecture:
- Monorepo: package names
- API + Frontend: `api`, `web`, `shared`
- Electron: `main`, `renderer`, `preload`, `shared`
- Pipeline: stage names
- Simple project: suggest omitting scopes

Let the user adjust.

## Phase 3: Adapt

Based on discovery + user answers, make the following changes:

### 3.1 Append to CLAUDE.md

Find the `<!-- bootstrap-claude: project-specific below -->` marker. Append below it:

```markdown
## Project Overview

**Project:** [name from package.json, go.mod, or directory name]
**Architecture:** [detected pattern]
**Tech Stack:** [confirmed stack]

## How to Build / Test / Run

| Command | Purpose |
|---------|---------|
| `[detected build command]` | Build the project |
| `[detected test command]` | Run tests |
| `[detected lint command]` | Run linter |
| `[detected validation command]` | Run full validation (REQUIRED before commits) |
| `[detected run/start command]` | Start the project locally |

**Validation command:** `[command]` — this is the hard gate for all workflow commands.

## Project Structure

[Describe the key directories and their purposes based on what was discovered]

## Issue Scopes

Scopes for commit messages and issue titles:
- `[scope1]`: [what it covers]
- `[scope2]`: [what it covers]
- [etc.]

## Architecture Rules

[Based on detected architecture pattern, add specific rules. Examples:]
- [For API+Frontend: "Frontend must use generated SDK for API calls — never raw fetch()"]
- [For Electron: "Renderer code never imports Node.js modules directly"]
- [For Pipeline: "Web server orchestrates via CLI subprocesses — never imports pipeline internals"]
- [For Monorepo: "Packages declare explicit dependencies — no implicit cross-package imports"]

## Key Files

| File/Directory | Purpose |
|---------------|---------|
| [detected key files] | [their purposes] |
```

### 3.2 Add Permissions to settings.local.json

Read the existing `settings.local.json` and add project-specific permissions. Determine which to add based on detected tech stack:

| Detected | Permissions to Add |
|----------|-------------------|
| Go | `Bash(go build:*)`, `Bash(go test:*)`, `Bash(go run:*)`, `Bash(go mod:*)` |
| Rust | `Bash(cargo build:*)`, `Bash(cargo test:*)`, `Bash(cargo run:*)`, `Bash(cargo clippy:*)` |
| Docker | `Bash(docker:*)`, `Bash(docker compose:*)`, `Bash(docker ps:*)`, `Bash(docker exec:*)` |
| PostgreSQL | `Bash(psql:*)` |
| SQLite | (covered by node/python) |
| Code generators (sqlc, oapi-codegen, openapi-ts) | Add specific `Bash(tool:*)` permissions |
| Ruff (Python) | `Bash(ruff:*)` |
| Additional WebFetch domains | `WebFetch(domain:relevant-docs-site.com)` for framework documentation sites |

Merge new permissions into the existing `allow` array — don't overwrite the baseline.

### 3.3 Create Project-Specific Skills

Based on the detected primary abstraction, create appropriate skills in `.claude/skills/`:

**For API projects (Go, Node/Express, Python/FastAPI, etc.):**
Create `.claude/skills/add-endpoint/SKILL.md` — workflow for adding a new API endpoint:
1. Define the route/endpoint
2. Add database query if needed (and run code generation if applicable)
3. Implement the handler
4. Wire the route
5. Create frontend integration (if frontend exists)
6. Write tests

**For React/frontend projects:**
Create `.claude/skills/add-component/SKILL.md` — workflow for adding a new component:
1. Determine file location by feature area
2. Define props interface/types
3. Identify data sources
4. Implement component following project conventions
5. Apply styling (Tailwind, CSS modules, etc.)
6. Write tests

**For pipeline/data processing projects:**
Create `.claude/skills/add-pipeline-step/SKILL.md` — workflow for adding a new processing stage:
1. Define CLI interface
2. Define input/output contracts
3. Implement core logic
4. Wire into orchestration
5. Update documentation
6. Write tests

**For all projects with docs/:**
Create `.claude/skills/update-docs/SKILL.md` — documentation audit:
1. Inventory all .md files
2. Verify file path references exist
3. Verify technical references match code
4. Check cross-references
5. Apply fixes
6. Report results

Customize each skill with the project's actual file paths, naming conventions, and patterns discovered in Phase 1.

### 3.4 Augment Code Reviewer

Find the `<!-- bootstrap-claude: project-specific checks below -->` marker in `.claude/agents/code-reviewer.md`. Append project-specific review criteria based on detected architecture:

**For Electron apps:**
- Process boundary compliance (renderer/main/preload isolation)
- Electron security checks (contextIsolation, nodeIntegration)
- IPC conventions

**For API-first projects:**
- SDK/client usage enforcement (no raw fetch)
- API spec compliance
- Service layer delegation

**For pipeline architectures:**
- Pipeline contract compliance (CLI contracts, JSON schemas)
- Selector/constant isolation
- Docker correctness

**For all projects:**
- Language-specific quality checks (TypeScript strict mode, Python type hints, Go error handling)
- Framework-specific patterns (React hooks rules, Next.js conventions)

### 3.5 Configure .mcp.json

If the project would benefit from additional MCP servers beyond context7, add them. Keep this conservative — only add servers that clearly match the project's needs.

### 3.6 Configure .gitignore

If the user chose to gitignore Claude config, append to `.gitignore`:

```
# Claude Code configuration
CLAUDE.md
.claude/
.mcp.json
```

If `.gitignore` doesn't exist, create it with these entries.

### 3.7 Settings.json Hooks

If the project has linters/formatters, create or update `.claude/settings.json` with PostToolUse hooks:

**For TypeScript projects:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "npx eslint --fix $CLAUDE_FILE_PATH 2>/dev/null || true",
        "timeout": 10000
      }]
    }]
  }
}
```

**For Python projects:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "ruff format $CLAUDE_FILE_PATH 2>/dev/null && ruff check --fix $CLAUDE_FILE_PATH 2>/dev/null || true",
        "timeout": 10000
      }]
    }]
  }
}
```

**For projects with sensitive files (.env):**
Add a PreToolUse hook:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "case \"$CLAUDE_FILE_PATH\" in *.env|*.env.*) echo 'BLOCKED: Do not edit .env files directly. Use .env.example as a template.' && exit 1;; esac",
        "timeout": 5000
      }]
    }]
  }
}
```

### 3.8 Documentation Scaffold

If the user opted in, create `docs/README.md`:

```markdown
# Documentation

This directory contains project documentation maintained by both humans and AI agents.

## Conventions

- **Keep docs current:** When making changes that affect documented behavior, update the relevant docs in the same PR.
- **One topic per file:** Each markdown file covers a single topic (architecture, API, deployment, etc.).
- **Link, don't duplicate:** Reference other docs rather than copying content.
- **Use concrete examples:** Include code snippets, commands, and expected outputs.
- **Date sensitive content:** If something might become outdated, note when it was last verified.

## Agent Guidelines

When Claude creates or updates documentation:
- Use clear, concise language
- Include file paths relative to project root
- Include runnable commands with expected outputs
- Update cross-references when renaming or moving content
- Never create tracking/planning documents here — use GitHub Issues instead

## Structure

| File | Purpose |
|------|---------|
| `README.md` | This file — documentation conventions |
| [Add more as the project grows] |
```

## Phase 4: Summary

After all changes, present a summary:

```
## Bootstrap Complete!

### Changes Made:
- CLAUDE.md: Appended project-specific configuration
- settings.local.json: Added [N] project-specific permissions
- Skills created: [list of skills]
- Code reviewer: Augmented with [project-type] checks
- [.gitignore updated (if applicable)]
- [docs/ scaffold created (if applicable)]
- [settings.json hooks added (if applicable)]

### What's Configured:
- Validation command: `[command]`
- Test command: `[command]`
- Issue scopes: [list]
- Architecture rules: [summary]

### Next Steps:
1. Review the changes — especially CLAUDE.md and the generated skills
2. Adjust anything that doesn't look right
3. Start working! Use `/triage` to analyze your backlog or `/create-issues` to plan new work.
```

## Checklist

- [ ] All project manifest files scanned (package.json, go.mod, etc.)
- [ ] Tech stack and framework detected correctly
- [ ] Build/test/validation commands identified
- [ ] User confirmed profile accuracy
- [ ] User chose git integration strategy
- [ ] User decided on docs scaffold
- [ ] CLAUDE.md appended with project-specific config
- [ ] Permissions updated for project tools
- [ ] Project-specific skills created
- [ ] Code reviewer augmented
- [ ] Hooks configured for formatters/linters
- [ ] Summary presented to user

## Rules

- ALWAYS scan before asking — present findings, don't ask the user to describe their project
- ALWAYS confirm with user before making changes
- NEVER overwrite baseline sections of CLAUDE.md — only append below the marker
- NEVER remove baseline permissions from settings.local.json — only add
- If re-bootstrapping (existing project-specific content detected), warn user and ask before overwriting
- Keep generated skills practical — don't create skills for patterns the project doesn't use
- Prefer detecting over guessing — if you can't determine something from the project files, ask
```

**Step 2: Verify the skill file**

Run: `wc -l golden/.claude/skills/bootstrap-claude/SKILL.md`
Expected: approximately 300+ lines

**Step 3: Commit**

```bash
git add golden/.claude/skills/bootstrap-claude/SKILL.md
git commit -m "feat: add bootstrap-claude skill

Self-adapting skill that scans project tech stack, confirms with user,
and generates project-specific CLAUDE.md sections, permissions, skills,
code reviewer augmentation, hooks, and documentation scaffold."
```

---

### Task 7: Create deploy.sh

**Files:**
- Create: `deploy.sh`

**Step 1: Write deploy.sh**

Write to `deploy.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# deploy.sh — Copy the golden set into a target project directory
#
# Usage:
#   ./deploy.sh /path/to/project
#   ./deploy.sh                    # prompts for target directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOLDEN_DIR="$SCRIPT_DIR/golden"

# Verify golden directory exists
if [ ! -d "$GOLDEN_DIR" ]; then
  echo "Error: golden/ directory not found at $GOLDEN_DIR"
  exit 1
fi

# Get target directory
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  read -rp "Target project directory: " TARGET
fi

# Expand ~ and resolve path
TARGET="${TARGET/#\~/$HOME}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

# Validate or create target
if [ ! -d "$TARGET" ]; then
  read -rp "Directory '$TARGET' does not exist. Create it? (y/N) " CREATE
  if [[ "$CREATE" =~ ^[Yy]$ ]]; then
    mkdir -p "$TARGET"
    echo "Created $TARGET"
  else
    echo "Aborted."
    exit 1
  fi
fi

# Check for existing config
EXISTING=()
[ -f "$TARGET/CLAUDE.md" ] && EXISTING+=("CLAUDE.md")
[ -d "$TARGET/.claude" ] && EXISTING+=(".claude/")
[ -f "$TARGET/.mcp.json" ] && EXISTING+=(".mcp.json")

if [ ${#EXISTING[@]} -gt 0 ]; then
  echo ""
  echo "Warning: Target already has Claude configuration:"
  printf "  - %s\n" "${EXISTING[@]}"
  echo ""
  read -rp "Overwrite? (y/N) " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "Aborted. Existing config preserved."
    exit 0
  fi
fi

# Copy golden set to target
echo ""
echo "Deploying golden set to $TARGET..."

# Copy CLAUDE.md
cp "$GOLDEN_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"

# Copy .claude/ directory (merge, don't delete existing)
mkdir -p "$TARGET/.claude"
cp -R "$GOLDEN_DIR/.claude/" "$TARGET/.claude/"

# Copy .mcp.json
cp "$GOLDEN_DIR/.mcp.json" "$TARGET/.mcp.json"

echo ""
echo "Done! Golden set deployed to $TARGET"
echo ""
echo "Files deployed:"
echo "  - CLAUDE.md (baseline configuration)"
echo "  - .claude/commands/ (workflow commands)"
echo "  - .claude/skills/bootstrap-claude/ (project adapter)"
echo "  - .claude/agents/code-reviewer.md (review agent)"
echo "  - .claude/settings.local.json (baseline permissions)"
echo "  - .mcp.json (MCP server config)"
echo ""
echo "Next step:"
echo "  cd $TARGET"
echo "  claude"
echo "  > /bootstrap-claude"
echo ""
echo "This will scan your project and adapt the configuration to your tech stack."
```

**Step 2: Make deploy.sh executable**

```bash
chmod +x deploy.sh
```

**Step 3: Verify deploy.sh runs**

```bash
bash -n deploy.sh  # syntax check only
```
Expected: no output (clean syntax)

**Step 4: Commit**

```bash
git add deploy.sh
git commit -m "feat: add deploy.sh

Simple script to copy the golden set into any target project directory.
Warns about existing config, creates target if needed."
```

---

### Task 8: Clean Up and Final Commit

**Files:**
- Delete: `claude/` (entire directory — old backup/restore system)

**Step 1: Remove old files**

```bash
rm -rf claude/
```

**Step 2: Verify clean state**

Run: `ls -la`
Expected: Only `golden/`, `deploy.sh`, `docs/`, and git files remain.

**Step 3: Commit removal**

```bash
git add -A
git commit -m "chore: remove old backup/restore system

Old project-specific configs (vistainspect, git_branch_tracker,
instagram-scraper) replaced by the golden set approach. Learnings
from all three projects are captured in the genericized commands,
code reviewer, and bootstrap-claude skill."
```

**Step 4: Verify final repo state**

Run: `find . -not -path './.git/*' -not -path './.git' -type f | sort`
Expected:
```
./deploy.sh
./docs/plans/2026-02-23-golden-set-bootstrap-design.md
./docs/plans/2026-02-23-golden-set-implementation.md
./golden/.claude/agents/code-reviewer.md
./golden/.claude/commands/close-issue.md
./golden/.claude/commands/create-issues.md
./golden/.claude/commands/review-pr.md
./golden/.claude/commands/setup-release.md
./golden/.claude/commands/triage.md
./golden/.claude/commands/wiggum.md
./golden/.claude/settings.local.json
./golden/.claude/skills/bootstrap-claude/SKILL.md
./golden/.mcp.json
./golden/CLAUDE.md
```
