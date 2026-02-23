# Golden Set + Bootstrap-Claude Design

**Date:** 2026-02-23
**Status:** Approved

## Problem

The dotfiles repo currently backs up and restores project-specific Claude configs between three projects. This is backwards — the repo should be the **source of truth**, not a mirror. We want a portable "golden set" of Claude configuration that can be dropped into any new project and then self-adapt to that project's unique needs.

## Decision

**Approach 1 + light markers:** A flat golden set directory that gets copied into target projects via a simple script. A bootstrap-claude skill then adapts the generic config to the specific project. Comment markers in CLAUDE.md delineate baseline vs. project-specific content.

## Repository Structure

```
dotfiles/
├── golden/                          # The deliverable — mirrors a project root
│   ├── CLAUDE.md                    # Baseline behaviors and conventions
│   ├── .claude/
│   │   ├── commands/
│   │   │   ├── wiggum.md
│   │   │   ├── close-issue.md
│   │   │   ├── create-issues.md
│   │   │   ├── review-pr.md
│   │   │   ├── triage.md
│   │   │   └── setup-release.md
│   │   ├── skills/
│   │   │   └── bootstrap-claude/
│   │   │       └── SKILL.md
│   │   ├── agents/
│   │   │   └── code-reviewer.md
│   │   └── settings.local.json
│   └── .mcp.json
├── deploy.sh
└── README.md
```

Everything inside `golden/` lands in the target project. `deploy.sh` is the only file that doesn't get copied.

## Golden CLAUDE.md

A baseline CLAUDE.md encoding universal behaviors:

- **Development philosophy:** TDD always. Issue-driven workflow — use GitHub Issues, never create tracking MD files in the repo. Validate before claiming completion.
- **Workflow commands:** Documents available slash commands (/wiggum, /triage, /close-issue, /review-pr, /create-issues, /setup-release, /bootstrap-claude) and when to use them.
- **Issue management:** All work tracked via GitHub Issues. Dependencies expressed in issue bodies. Epics via parent issues.
- **Code quality:** Run validation before any commit. Follow existing project conventions. Don't over-engineer.
- **PR workflow:** Every change gets a PR. PRs link to issues. Use /review-pr before merging.
- **Bootstrap marker:** A `<!-- bootstrap-claude: project-specific below -->` section where /bootstrap-claude appends project-specific instructions.

Deliberately generic — no mention of specific languages, frameworks, or file paths. Bootstrap fills those in.

## Bootstrap-Claude Skill

A skill at `.claude/skills/bootstrap-claude/SKILL.md`. Three phases:

### Phase 1: Discovery

Scans the project to build a profile:
- **Tech stack:** package.json, go.mod, Cargo.toml, requirements.txt, Makefile, Dockerfile, docker-compose.yml
- **Build/test tooling:** Test runners, linters, formatters, build commands
- **CI/CD:** .github/workflows, Jenkinsfile, .gitlab-ci.yml
- **Existing docs:** README.md, docs/ directory, any markdown knowledge base
- **Existing Claude config:** Checks for pre-existing CLAUDE.md or .claude/ (re-bootstrap case)
- **Git state:** Is this a git repo? Does .gitignore exist?

### Phase 2: Confirm with User

Presents findings and asks:

1. **"Here's what I detected — is this accurate?"** — Tech stack, test commands, build commands, project structure summary. User corrects anything wrong.
2. **"Should Claude config files be checked into git or gitignored?"** — Check in (team shares config) vs. add to .gitignore (personal config).
3. **"I don't see a docs/knowledge base. Should I create one?"** — If no docs/ or similar directory exists, offer to create a docs/ directory with a bootstrapped README that guides future agent behavior around documentation conventions.

### Phase 3: Adapt

Based on discovery + user answers:

1. **CLAUDE.md** — Appends project-specific sections below the `<!-- bootstrap-claude: project-specific below -->` marker: project overview, build/test/lint/run commands, project conventions, key file paths.
2. **Permissions** — Adds project-specific tool permissions to settings.local.json (e.g., go build, cargo test, docker compose).
3. **Skills** — Creates project-specific skills based on detected patterns (Go API → add-endpoint; React → add-component; pipeline → add-pipeline-step).
4. **Code reviewer** — Augments the generic code-reviewer agent with project-specific review criteria.
5. **.mcp.json** — Adds project-relevant MCP servers.
6. **.gitignore** — If user chose to gitignore Claude config, adds CLAUDE.md, .claude/, .mcp.json entries.
7. **Docs scaffold** — If user opted in, creates docs/README.md with documentation conventions for future agent sessions.

## deploy.sh

```
./deploy.sh [target-directory]
```

- If no target provided, prompts for it
- Validates target directory exists (or creates it)
- Copies everything from golden/ into target, preserving directory structure
- If target already has CLAUDE.md or .claude/, warns and asks whether to overwrite or skip
- On success, prints instructions to run /bootstrap-claude

No merge logic, no diffing — just a clean copy.

## Migration Plan

1. **Mine existing configs** — Read all three project-specific configs and the default set. Extract universal patterns for the golden CLAUDE.md, command improvements, generic code reviewer patterns, and baseline permissions.
2. **Build the golden set** — Create golden/ with all curated files.
3. **Build deploy.sh** — The copy script.
4. **Build bootstrap-claude** — The self-adapting skill.
5. **Remove old files** — Delete claude/ directory, backup.sh, restore.sh, projects.conf.
6. **Initialize git** — This repo isn't currently a git repo. Initialize and commit.
