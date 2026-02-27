---
name: update-claude
description: Pull golden set updates into a bootstrapped project while preserving project-specific customizations
user_invocable: true
---

# /update-claude — Golden Set Update

Run this command from a bootstrapped project. Point it at the golden set repo to pull in new and changed golden set content while preserving all project-specific customizations. This is the forward update flow — after the golden set evolves (via `/improve-golden-set` or direct edits), use this command to propagate those improvements into existing projects.

## Invocation

```
/update-claude ~/dev/shared/dotfiles
```

If no path argument is provided, ask the user for one. Do not proceed without a valid path.

## Steps

### 1. Validate the golden set path

Confirm the golden set path:
- Directory exists
- Has `golden/` subdirectory
- `golden/CLAUDE.md` exists
- `golden/.claude/commands/` directory exists

If any check fails, report the specific problem and stop.

### 2. Validate the current project

Confirm the current project:
- Has `CLAUDE.md` at the project root
- `CLAUDE.md` contains the bootstrap marker (`<!-- bootstrap-claude: project-specific below -->`)
- Has `.claude/` directory

If any check fails, report the specific problem and stop.

### 3. Diff CLAUDE.md baseline

Extract the project's baseline — everything above the bootstrap marker (`<!-- bootstrap-claude: project-specific below -->`). Compare it against `golden/CLAUDE.md`.

Classify the baseline as one of:
- **Identical:** Project baseline matches golden CLAUDE.md exactly
- **Golden updated:** Golden has changes the project baseline does not
- **Project modified:** Project changed its baseline, golden has the old version
- **Diverged:** Both sides differ from each other

### 4. Diff commands

For each file in `golden/.claude/commands/*.md`, check whether a matching file exists in the project's `.claude/commands/`:

- **New:** File exists in golden but not in the project
- **Unchanged:** File is identical in both
- **Golden updated:** Golden version differs, and the project has the older version
- **Project modified:** Project version differs, and golden has the older version
- **Diverged:** Both sides differ from each other

Ignore project commands that do not exist in the golden set — those are project-specific and must be left alone.

**Note:** Without version tracking, distinguishing "Golden updated" from "Project modified" may not always be possible. When in doubt, classify as **Diverged** and let the user decide.

### 4b. Diff agent_docs

For each file in `golden/agent_docs/*.md`, check whether a matching file exists in the project's `agent_docs/`:

- **New:** File exists in golden but not in the project
- **Unchanged:** File is identical in both
- **Golden updated:** Golden version differs, and the project has the older version
- **Project modified:** Project version differs, and golden has the older version
- **Diverged:** Both sides differ from each other

Ignore project `agent_docs/` files that do not exist in the golden set — those are project-specific reference docs and must be left alone.

### 5. Diff agents

For each file in `golden/.claude/agents/*.md`, check whether a matching file exists in the project's `.claude/agents/`:

Apply the same classification as commands: **New**, **Unchanged**, **Golden updated**, **Project modified**, **Diverged**.

For agents with a bootstrap marker (`<!-- bootstrap-claude: project-specific checks below -->`), only compare content above the marker. Content below the marker is project-specific and must be ignored during comparison.

Ignore project agents that do not exist in the golden set.

### 6. Diff settings.local.json

Parse the `allow` arrays from both `golden/.claude/settings.local.json` and the project's `.claude/settings.local.json`.

Identify permissions present in the golden set but absent from the project — these are new baseline permissions.

Never flag project-specific permissions for removal. Project permissions that are not in the golden set are project-specific and must be left alone.

### 7. Diff .mcp.json

Compare server configurations between `golden/.mcp.json` and the project's `.mcp.json`.

Identify new servers in the golden set that are not in the project. Identify servers that exist in both but have different configurations.

Never flag project-specific servers for removal.

### 7b. Diff governance files

Compare `golden/BUDGETS.md` against the project's `BUDGETS.md` (if it exists):
- If the project has no `BUDGETS.md`, flag as **New** — recommend adding
- If both exist, diff and classify as **Unchanged**, **Golden updated**, **Project modified**, or **Diverged**

Similarly, compare `golden/CHANGELOG.md` against the project's `CHANGELOG.md`.

### 8. Check for removed golden items

Check for files that exist in the project's `.claude/commands/` or `.claude/agents/` that match golden set naming patterns but no longer exist in the golden set. These are items that were previously deployed from golden but have since been removed from it.

Skip project-specific commands generated by `/bootstrap-claude` (e.g., `add-endpoint.md`, `add-component.md`, `add-pipeline-step.md`, `update-docs.md`) — these were never part of the golden set. Only flag files whose names suggest golden set origin but are no longer present in the golden set.

### 9. Assess results

If everything is identical across all categories, report:

```
Already up to date. No golden set changes to apply.
```

Stop here if nothing changed.

### 10. Present changes for approval

Group findings by type and present each change individually for user approval.

**New items** (in golden, not in project):
- List each with a brief summary of its content
- Default recommendation: add
- Example: "New command `/improve-golden-set` — extract improvements from bootstrapped projects back into the golden set. Add to this project?"

**Updated items** (golden changed, project has old version):
- Show the diff between the golden version and the project version
- Default recommendation: update
- Example: "Command `/triage` updated in golden set. Changes: [diff summary]. Update?"

**Diverged items** (both sides changed):
- Show both versions side by side
- Ask the user to choose: accept golden version, keep project version, or describe a merge
- Example: "Command `/close-issue` differs in both golden and this project. Golden version: [content summary]. Project version: [content summary]. Which to keep?"

**Removed from golden** (project has a golden item that golden no longer includes):
- Flag for user awareness
- Default recommendation: remove
- Example: "Command `/old-command` was removed from golden set but still exists here. Remove?"

Wait for the user to approve or reject each change before proceeding.

### 11. Apply approved changes

For each approved change:

**New commands/agents/agent_docs:** Copy from golden to the project's corresponding directory. Create `agent_docs/` if it doesn't exist.

**Updated commands/agents/agent_docs:** Replace the project's version with the golden version.

**CLAUDE.md baseline updates:** Replace the project's baseline section (everything above the bootstrap marker) with the golden version. Preserve everything below the marker untouched.

**Agent updates with bootstrap markers:** Replace only the content above the agent's bootstrap marker with the golden version. Preserve everything below the agent marker untouched.

**New permissions:** Merge new golden permissions into the project's `settings.local.json` `allow` array. Do not remove any existing permissions.

**MCP changes:** Add new servers or update changed server configurations in the project's `.mcp.json`. Do not remove project-specific servers.

**Governance files (BUDGETS.md, CHANGELOG.md):** Copy or update as approved. For CHANGELOG.md, the project's changelog will be replaced — warn the user if the project has local-only entries.

**Diverged items (golden chosen):** Replace the project version with the golden version.

**Diverged items (project chosen):** No change.

**Removed items (approved for removal):** Delete the file from the project.

### 11b. Post-Application Budget Audit

After applying all changes, re-measure the project's CLAUDE.md against `BUDGETS.md`:

1. Count baseline lines and instructions (above marker)
2. Count project-specific lines and instructions (below marker)
3. Count total combined
4. If any budget is exceeded, warn:

   "Budget exceeded: CLAUDE.md baseline is now NN lines (budget: 60). Consider running /slim to identify compression or relocation opportunities."

### 12. Summary

Present a summary of all changes applied:

```
## Update Complete

### Changes Applied:
- CLAUDE.md baseline: Updated (N sections changed)
- Commands added: /command-a, /command-b
- Commands updated: /command-c
- Agents updated: code-reviewer.md
- agent_docs/ added: issue-conventions.md
- agent_docs/ updated: self-improvement.md
- Governance files: BUDGETS.md updated
- Permissions added: N new baseline permissions
- MCP servers added: server-name
- Commands removed: /old-command

### Budget Utilization:
- CLAUDE.md baseline: NN/60 lines (NN%), NN/25 instructions (NN%)
- CLAUDE.md project-specific: NN/80 lines (NN%), NN/30 instructions (NN%)

### Unchanged:
- Project-specific CLAUDE.md sections: preserved
- Project-specific commands: untouched
- Project-specific agent augmentations: preserved
- Project-specific agent_docs/: preserved
- Project-specific permissions: preserved
- Project-specific MCP servers: preserved

### Next Steps:
1. Review the changes
2. Run the project's validation command to verify nothing broke
3. Commit when satisfied
```

## Rules

- NEVER modify content below the bootstrap marker in CLAUDE.md
- NEVER remove project-specific permissions from settings.local.json
- NEVER remove project-specific commands (those not in the golden set)
- NEVER remove project-specific MCP servers
- NEVER auto-apply changes — always present each change for user approval
- NEVER touch `.claude/lessons.md`, `tasks/todo.md`, or `.claude/settings.json` (hooks)
- ALWAYS preserve project-specific agent augmentations (content below agent bootstrap markers)
- If the project's CLAUDE.md baseline diverged from golden, show both versions and let the user decide
- If a command was both modified locally and updated in golden, treat as diverged — never silently overwrite
