# Claude Bootstrapping

A portable configuration kit for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Deploy a battle-tested set of workflow commands, agents, and conventions into any project, then run a single skill to adapt everything to the local tech stack.

## Why

Starting Claude Code in a new project means rebuilding the same scaffolding every time: issue workflows, PR conventions, TDD discipline, code review checklists. This repo packages all of that into a **golden set** — a baseline configuration that works out of the box and adapts to your project with one command.

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/quadradad/claude-bootstrapping.git
cd claude-bootstrapping

# 2. Deploy the golden set into your project
./deploy.sh /path/to/your/project

# 3. Open Claude Code in the project and bootstrap
cd /path/to/your/project
claude
> /bootstrap-claude
```

`/bootstrap-claude` scans your project, detects the tech stack, and writes project-specific configuration (validation commands, architecture rules, scopes, permissions, and more) into CLAUDE.md.

## What's in the Golden Set

```
golden/
├── CLAUDE.md                          # Baseline project config
├── .mcp.json                          # MCP server config (context7)
└── .claude/
    ├── settings.local.json            # Pre-approved tool permissions
    ├── agents/
    │   └── code-reviewer.md           # Automated code review agent
    ├── commands/
    │   ├── wiggum.md                  # Autonomous dev loop
    │   ├── triage.md                  # Backlog analysis & dependency graphing
    │   ├── create-issues.md           # Plan-to-issues pipeline
    │   ├── close-issue.md             # Issue validation & closure
    │   ├── setup-release.md           # Release planning & milestone setup
    │   └── review-pr.md              # Standardized PR review
    └── skills/
        └── bootstrap-claude/
            └── SKILL.md               # Project adapter skill
```

### CLAUDE.md

The central configuration file. Contains:

- **Development philosophy** — TDD, issue-driven workflow, YAGNI, DRY, plan-before-building, challenge-your-work, fix-bugs-autonomously
- **Issue management** — Structured format for titles, bodies, dependencies, and acceptance criteria
- **Issue tracker** — Operations reference table with CLI commands for all issue/milestone operations. Defaults to GitHub Issues (`gh` CLI); swappable to Jira, Linear, or GitLab by updating this one section
- **Subagent strategy** — Guidelines for keeping the main context clean by offloading to subagents
- **Session start ritual** — Review lessons, assess state, decide next action at the beginning of each session
- **Continuous improvement** — Self-improvement loop via `.claude/lessons.md`, triggered by corrections and PR reviews
- **Commit & PR conventions** — Conventional commits, smart close syntax, branch naming
- **Workflow command reference** — Quick lookup for all available `/commands`

Below a bootstrap marker, `/bootstrap-claude` appends project-specific configuration: tech stack, build/test/validation commands, architecture rules, scopes, and key files.

### Workflow Commands

| Command | What it does |
|---------|-------------|
| `/wiggum` | Fully autonomous dev loop. Picks the next unblocked issue by impact score, branches, implements with TDD, validates, creates a PR, closes the issue, and repeats until the milestone is done. |
| `/triage` | Fetches all open issues, builds a dependency graph, detects cycles, classifies readiness, validates labels, and produces a prioritized backlog report. |
| `/create-issues` | Takes a plan from conversation and creates a structured set of issues — tracking epic, dependency links, acceptance criteria, and optional assignee resolution. |
| `/close-issue` | Quality gate for issue closure. Validates acceptance criteria against the implementation, checks off criteria on the issue, posts a structured closing comment, and reports downstream unblocks. |
| `/setup-release` | Scopes a release by filtering issues, creates a milestone, sets up a release branch, generates a phased implementation plan, and creates a draft PR with progress tracking. |
| `/review-pr` | Seven-section PR review: metadata, architecture compliance, holistic update check, code quality, test coverage, security, and build gates. Produces a structured verdict. |

### Code Reviewer Agent

A subagent used by `/review-pr` and available independently. Checks architecture compliance, code quality, test coverage, security, and general hygiene against the rules in CLAUDE.md. Extensible via a bootstrap marker for project-specific checks.

### Issue Tracker Abstraction

All workflow commands reference issue tracker operations by name (e.g., **list open issues**, **create issue**, **close issue**) rather than hardcoding CLI commands. The actual commands live in a single Operations Reference table in CLAUDE.md.

This means swapping from GitHub Issues to Jira, Linear, or GitLab is a config change in one place — not a find-and-replace across every command. `/bootstrap-claude` handles this automatically when it detects a non-GitHub tracker.

### Baseline Permissions

`settings.local.json` pre-approves common tool permissions so Claude doesn't prompt for every git, gh, npm, or python command. `/bootstrap-claude` adds project-specific permissions (e.g., `go build`, `cargo test`, `docker compose`) based on the detected stack.

## The Deploy Script

`deploy.sh` copies the golden set into a target project:

```bash
./deploy.sh /path/to/project
```

- Prompts before overwriting existing configuration
- Creates the target directory if it doesn't exist
- Merges into existing `.claude/` directories without deleting project-specific files

It does **not** modify any configuration — that's what `/bootstrap-claude` is for.

## The Bootstrap Skill

`/bootstrap-claude` is the bridge between the generic golden set and your specific project. It runs in four phases:

1. **Discovery** — Scans for package manifests, framework configs, build tools, CI/CD, documentation, project structure, issue tracker signals, and git state
2. **Confirm** — Presents findings and asks targeted questions: profile accuracy, git integration strategy, documentation scaffold, issue scopes, tracker selection, and task tracking mode (external tracker vs in-repo `tasks/todo.md`)
3. **Adapt** — Appends project-specific config to CLAUDE.md, adds tool permissions, creates project-specific skills (e.g., `add-endpoint` for APIs, `add-component` for React), augments the code reviewer, configures formatter hooks, and sets up the issue tracker
4. **Summary** — Reports everything that was configured and suggests next steps

## Reference Workflow

These commands were built to support a specific development loop. Here's the workflow they were designed around — adapt it however you like.

### 1. Plan

For larger features, hand Claude a markdown file with requirements. For smaller work, just describe what you need and ask it to put together a plan. Either way, you end up with a conversation where the scope, approach, and sequencing are agreed on before any code is written.

### 2. Break it down

Once the plan looks right, run `/create-issues`. Claude converts the plan into a structured set of issues — a tracking epic, individual tasks with acceptance criteria, a dependency graph, labels, and a sequenced implementation order. Everything lands in your issue tracker ready to execute.

### 3. Let it work

Run `/wiggum` on the tracking issue and watch it go. It picks up tasks in dependency order, creates a feature branch, writes tests first, implements, runs validation, fixes what breaks, expands test coverage — then opens a PR, merges it back into the working branch, and moves to the next task. This continues autonomously until the milestone is complete.

### 4. Review

When the work is done, create a PR to your main branch and run `/review-pr`. It performs a structured seven-section review: architecture compliance, code quality, test coverage, security, and more. If the review finds issues Claude introduced, it automatically captures lessons in `.claude/lessons.md` to prevent recurrence.

### 5. Iterate

If the review surfaces issues, tell Claude to create issues for the findings, then run `/wiggum` on the new tracking issue. Same loop, same discipline — the review feedback gets the same structured treatment as the original feature work.

This cycle — plan, break down, execute, review, iterate — is the core loop. The commands handle the mechanical parts so you can focus on requirements and review.

## Customization

The golden set is designed to be forked and modified:

- **Add commands** — Drop new `.md` files in `golden/.claude/commands/`
- **Add skills** — Create new directories in `golden/.claude/skills/`
- **Adjust conventions** — Edit the baseline sections of `golden/CLAUDE.md`
- **Change defaults** — Modify `golden/.claude/settings.local.json` for different baseline permissions

After deploying, project-specific customization goes below the bootstrap marker in CLAUDE.md — the golden set baseline stays above it.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`) — for the default issue tracker configuration
- Git

## License

MIT
