# Design: update-claude-manifest.sh

## Problem

When `/update-claude` runs in a bootstrapped project, Claude (the AI) does its own file discovery to compare golden set contents against the project. This is unreliable — Claude may miss directories (especially skills), fail to glob correctly, or skip categories entirely. The user reported that new skills weren't found even though the command attempted to look.

## Solution

A standalone shell script (`update-claude-manifest.sh`) that produces a structured text manifest comparing golden set contents against a target project. The `/update-claude` command runs this script first and uses its output as the authoritative inventory for all subsequent diff steps.

## Script: `update-claude-manifest.sh`

**Location:** Repository root (next to `deploy.sh`)

**Usage:** `bash <golden-path>/update-claude-manifest.sh <golden-path> <project-path>`

**Behavior:**
- Lists files/directories in each category for both golden and project
- Computes `new` items (in golden, not in project) per category
- Outputs structured text to stdout
- Exits 0 always (informational only, no failure states)
- No content diffing — presence/absence only

**Categories** (matching update-claude steps):
1. CLAUDE.md — exists/missing
2. COMMANDS — `*.md` files in `.claude/commands/`
3. AGENTS — `*.md` files in `.claude/agents/`
4. SKILLS — subdirectories in `.claude/skills/` (by directory name, not file)
5. AGENT_DOCS — `*.md` files in `agent_docs/`
6. SETTINGS — `.claude/settings.local.json` exists/missing
7. MCP — `.mcp.json` exists/missing
8. GOVERNANCE — `BUDGETS.md`, `CHANGELOG.md` at root

**Output format:**
```
=== CATEGORY ===
golden: item1 item2 item3
project: item1 item2
new: item3
```

For single-file categories (CLAUDE.md, SETTINGS, MCP):
```
=== CLAUDE.md ===
golden: exists
project: exists
```

## Changes to `update-claude.md`

Insert a new step between current steps 1 (validate golden set path) and 2 (validate current project):

> **Step 1.5: Run discovery manifest**
>
> Run the manifest script and capture its output:
> ```
> bash <golden-path>/update-claude-manifest.sh <golden-path> .
> ```
> Use this output as the authoritative file inventory for all subsequent steps. Do not independently glob or list files — trust the manifest.

Update steps 3-11 to reference the manifest output rather than doing their own file discovery. The steps still do content comparison (reading and diffing file contents), but they use the manifest to know which files to compare.

## What this does NOT change

- The approval flow (user approves each change) stays the same
- Content diffing (reading files, comparing text) stays Claude-driven
- The step structure of update-claude stays the same (just adds 1.5 and references manifest)
- deploy.sh is untouched
