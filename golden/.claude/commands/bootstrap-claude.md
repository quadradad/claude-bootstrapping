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

### Issue Tracker Detection

| Signal | Indicates |
|--------|-----------|
| `.github/` + `gh` available | GitHub Issues (default) |
| `.jira.d/`, `JIRA_*` env vars | Jira |
| `.linear` config | Linear |
| `.gitlab-ci.yml`, `GITLAB_*` env vars | GitLab Issues |

### Git State

- Is this a git repo? (`git rev-parse --is-inside-work-tree`)
- Does `.gitignore` exist?
- Are there existing branches? What's the default branch?

### Existing Claude Config

- Does `CLAUDE.md` already have content below the bootstrap marker?
- Are there existing project-specific commands in `.claude/commands/`?
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

### Question 5: Issue Tracker

If a non-GitHub tracker was detected in Phase 1, ask:

**"What issue tracker does this project use?"**

Options:
- **GitHub Issues** (default) — uses `gh` CLI
- **Jira** — uses `jira` CLI or REST API
- **Linear** — uses `linear` CLI or GraphQL API
- **GitLab Issues** — uses `glab` CLI

If no non-GitHub tracker was detected, default silently to GitHub Issues without asking.

### Question 6: Task Tracking Mode

Always ask this question:

**"How should this project track tasks?"**

Options:
- **External issue tracker** (default) — Full workflow command support with the tracker configured above.
- **In-repo task file** (`tasks/todo.md`) — Lightweight tracking for solo projects or when an external tracker is managed elsewhere. Labels, milestones, and assignees are not available.

## Phase 3: Adapt

Based on discovery + user answers, make the following changes:

### 3.0 Classify generated content

Before writing to CLAUDE.md or agent_docs/, classify each section by destination:

**Into CLAUDE.md (project-specific, below marker) — behavioral instructions only:**
- Project Overview (3 lines max: name, architecture, stack)
- Validation command (one-liner — the behavioral trigger)
- Architecture Rules (instructions that change behavior on unrelated tasks)
- Issue Scopes (one-line list)

**Into agent_docs/ (project reference data):**
- Build/Test/Run command table → `agent_docs/build-and-test.md`
- Project Structure descriptions → `agent_docs/project-structure.md`
- Key Files reference → `agent_docs/key-files.md`
- Project-specific tracker operations (if non-GitHub) → `agent_docs/issue-tracker-ops.md` (extend existing)

**Classification test:** "If I removed this from CLAUDE.md, would Claude's behavior change on tasks that don't directly involve this topic?" YES → CLAUDE.md. NO → agent_docs/.

### 3.1 Append to CLAUDE.md

Find the `<!-- bootstrap-claude: project-specific below -->` marker. Append below it. Only behavioral instructions and pointers — reference data goes to agent_docs/ in Step 3.1b.

```markdown
## Project Overview

**Project:** [name from package.json, go.mod, or directory name]
**Architecture:** [detected pattern]
**Tech Stack:** [confirmed stack]

## How to Build / Test / Run

**Validation command:** `[command]` — this is the hard gate for all workflow commands. For all build/test/run commands, see `agent_docs/build-and-test.md`.

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

For project structure and key files, see `agent_docs/project-structure.md`.
```

### 3.1b Create project-specific agent_docs

Create the following reference files in `agent_docs/`:

**`agent_docs/build-and-test.md`:**
```markdown
# Build & Test Commands
> Reference document. Loaded by workflow commands when running build/test operations.

| Command | Purpose |
|---------|---------|
| `[detected build command]` | Build the project |
| `[detected test command]` | Run tests |
| `[detected lint command]` | Run linter |
| `[detected validation command]` | Run full validation (REQUIRED before commits) |
| `[detected run/start command]` | Start the project locally |
```

**`agent_docs/project-structure.md`:**
```markdown
# Project Structure & Key Files
> Reference document. Loaded when navigating or modifying project architecture.

## Directory Structure
[Describe key directories and their purposes based on what was discovered]

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

### 3.3 Create Project-Specific Commands

Based on the detected primary abstraction, create appropriate commands in `.claude/commands/`:

**For API projects (Go, Node/Express, Python/FastAPI, etc.):**
Create `.claude/commands/add-endpoint.md` — workflow for adding a new API endpoint:
1. Define the route/endpoint
2. Add database query if needed (and run code generation if applicable)
3. Implement the handler
4. Wire the route
5. Create frontend integration (if frontend exists)
6. Write tests

**For React/frontend projects:**
Create `.claude/commands/add-component.md` — workflow for adding a new component:
1. Determine file location by feature area
2. Define props interface/types
3. Identify data sources
4. Implement component following project conventions
5. Apply styling (Tailwind, CSS modules, etc.)
6. Write tests

**For pipeline/data processing projects:**
Create `.claude/commands/add-pipeline-step.md` — workflow for adding a new processing stage:
1. Define CLI interface
2. Define input/output contracts
3. Implement core logic
4. Wire into orchestration
5. Update documentation
6. Write tests

**For all projects with docs/:**
Create `.claude/commands/update-docs.md` — documentation audit:
1. Inventory all .md files
2. Verify file path references exist
3. Verify technical references match code
4. Check cross-references
5. Apply fixes
6. Report results

Customize each command with the project's actual file paths, naming conventions, and patterns discovered in Phase 1.

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
- Never create tracking/planning documents here — use the project's issue tracker instead

## Structure

| File | Purpose |
|------|---------|
| `README.md` | This file — documentation conventions |
| [Add more as the project grows] |
```

### 3.9 Configure Issue Tracker

Fill in the CLAUDE.md Issue Tracker section based on the detected (or user-selected) tracker:

**For GitHub Issues (default):** No changes needed — the baseline `agent_docs/issue-tracker-ops.md` already has GitHub CLI commands.

**For Jira:**
- **Tool:** Jira CLI (`jira`) or REST API
- **Issue reference format:** `PROJ-NN` (e.g., `PROJ-53`)
- **Smart close syntax:** Jira smart commits (e.g., `PROJ-53 #close`)
- Update `agent_docs/issue-tracker-ops.md` with Jira CLI equivalents
- Add `Bash(jira:*)` to settings.local.json permissions

**For Linear:**
- **Tool:** Linear CLI (`linear`) or GraphQL API
- **Issue reference format:** `TEAM-NN` (e.g., `ENG-53`)
- **Smart close syntax:** `Fixes TEAM-NN`
- Update `agent_docs/issue-tracker-ops.md` with Linear CLI equivalents
- Add `Bash(linear:*)` to settings.local.json permissions

**For GitLab Issues:**
- **Tool:** GitLab CLI (`glab`)
- **Issue reference format:** `#NN` (same as GitHub)
- **Smart close syntax:** `Closes #NN`
- Update `agent_docs/issue-tracker-ops.md` with `glab` CLI equivalents
- Add `Bash(glab:*)` to settings.local.json permissions

### 3.10 Configure Task Tracking Mode

If the user selected **in-repo task file** in Question 6:

**Create `tasks/todo.md`** with the standard template:

```markdown
# Tasks

## Active

| ID | Type | Title | Status | Blocked by |
|----|------|-------|--------|------------|

## Done

| ID | Type | Title | Completed |
|----|------|-------|-----------|
```

**Modify CLAUDE.md:**
- Issue-Driven Workflow bullet → reference `tasks/todo.md` instead of external tracker
- Issue Management header → "All work is tracked in `tasks/todo.md`"
- Replace Issue Tracker section with a Task Tracker section:
  - Task reference format: `T-NN`
  - Commit reference: `Completes T-NN`
  - Dependency format: `- Blocked by: T-NN — reason`
  - `agent_docs/issue-tracker-ops.md` with file read/write operations instead of CLI commands
- Commit Conventions: `Closes #NN` → `Completes T-NN`

**Create `.claude/lessons.md`** with an empty template (this is created regardless of tracking mode):

```markdown
# Lessons Learned

Patterns learned from corrections and reviews. See `agent_docs/self-improvement.md`.
```

### 3.11 Post-bootstrap budget check

After all Phase 3 changes:

1. Count CLAUDE.md total lines (baseline + project-specific)
2. Count against combined budget from `BUDGETS.md`: 60 (baseline) + 80 (project) = 140 max lines
3. If over budget, identify which generated sections can be moved to `agent_docs/`
4. Report in the Phase 4 summary:
   - "CLAUDE.md: NN/140 lines (NN%). Budget: healthy / warning / exceeded."

## Phase 4: Summary

After all changes, present a summary:

```
## Bootstrap Complete!

### Changes Made:
- CLAUDE.md: Appended project-specific configuration
- agent_docs/: Created project reference docs (build-and-test.md, project-structure.md)
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
- CLAUDE.md: NN/140 lines (NN%). Budget: [healthy / warning / exceeded]

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
- [ ] Task tracking mode selected and configured
- [ ] Summary presented to user

## Rules

- ALWAYS scan before asking — present findings, don't ask the user to describe their project
- ALWAYS confirm with user before making changes
- NEVER overwrite baseline sections of CLAUDE.md — only append below the marker
- NEVER remove baseline permissions from settings.local.json — only add
- If re-bootstrapping (existing project-specific content detected), warn user and ask before overwriting
- Keep generated skills practical — don't create skills for patterns the project doesn't use
- Prefer detecting over guessing — if you can't determine something from the project files, ask
