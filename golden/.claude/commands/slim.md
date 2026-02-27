---
name: slim
description: Audit the golden set for bloat, redundancy, and budget compliance — compress or remove content to stay within limits
user_invocable: true
---

# /slim — Golden Set Audit & Compression

Audit CLAUDE.md and agent_docs/ for bloat, redundancy, and instructions that can be removed or compressed.

## When to run

- After every 5th `/improve-golden-set` cycle
- When any file reaches 80% of its budget (flagged by `/improve-golden-set` Step 11)
- On user request

## Steps

### 1. Measure current state

Count lines and instructions for every file listed in `BUDGETS.md`. Report current utilization:

```
## Current Budget Utilization

| File | Lines | Budget | % | Instructions | Budget | % |
|------|-------|--------|---|-------------|--------|---|
| CLAUDE.md (baseline) | NN | 60 | NN% | NN | 25 | NN% |
| CLAUDE.md (project) | NN | 80 | NN% | NN | 30 | NN% |
| agent_docs/issue-conventions.md | NN | 120 | NN% | — | — | — |
| agent_docs/issue-tracker-ops.md | NN | 120 | NN% | — | — | — |
| agent_docs/self-improvement.md | NN | 120 | NN% | — | — | — |
| .claude/lessons.md | NN entries | 40 | NN% | — | — | — |
| settings.local.json (allow) | NN entries | 100 | NN% | — | — | — |
```

Use the instruction counting rules from `BUDGETS.md` § "What counts as an instruction".

### 2. Redundancy scan

For each instruction in CLAUDE.md, check:

- **Duplicated in commands?** — If a command file already enforces this rule in its steps, the CLAUDE.md instruction may be redundant.
- **Trained-in behavior?** — Is this something the model does well by default without being told? (e.g., "follow existing conventions", "no hardcoded values")
- **Internal duplication?** — Is this instruction stated twice in CLAUDE.md under different wording?

Flag duplicates and trained-in behaviors for removal. Present evidence for each flag (which command enforces it, or why it's trained-in).

### 3. Lessons.md pruning

Read `.claude/lessons.md` and evaluate each entry:

- **Promoted:** Has this lesson been encoded into a CLAUDE.md instruction or command rule? → Flag for removal (note: "Promoted to [location]")
- **Project-specific:** Is this lesson specific to one project rather than universal? → Keep in project but don't extract to golden
- **Mergeable:** Are there 2+ lessons that express the same underlying principle? → Flag for merge into one generalized lesson
- **Stale:** No matching incidents in recent project context → Flag for archival to `.claude/lessons-archive.md`

### 4. Reference data audit

For each file in `agent_docs/`:

- **Accuracy:** Is the reference data still correct? (Check CLI commands, format specs)
- **Referenced:** Is it referenced by at least one command? (Dead references → flag for removal)
- **Current:** Has the format or tooling changed since this was written?

### 5. Present findings

Group all findings into categories:

```
## Audit Findings

### Remove (N items)
- [item] — [reason: redundant with command X / trained-in / promoted]

### Merge (N items)
- [lesson A] + [lesson B] → [merged version]

### Compress (N items)
- [item]: current NN lines → proposed NN lines
  [show compressed version]

### Keep (N items)
- [item] — [reason it's still valuable]
```

Wait for user approval before applying any changes.

### 6. Apply approved changes

For each approved change:
- Remove flagged content from CLAUDE.md, lessons.md, or agent_docs/
- Merge lessons as approved
- Apply compressed versions
- Move stale lessons to `.claude/lessons-archive.md`

### 7. Post-audit measurement

Re-measure all budgeted files and report before/after:

```
## Audit Results

| File | Before | After | Change |
|------|--------|-------|--------|
| CLAUDE.md baseline | NN/60 (NN%) | NN/60 (NN%) | -N lines |
| lessons.md | NN/40 entries | NN/40 entries | -N entries |
| ... | ... | ... | ... |
```

### 8. Changelog entry

Append an entry to `golden/CHANGELOG.md`:

```markdown
## [Date] — /slim audit

### Removed
- [items removed with reasons]

### Merged
- [lessons merged]

### Compressed
- [items compressed]

### Budget impact
- CLAUDE.md baseline: NN/60 → NN/60 lines (-N)
- lessons.md: NN/40 → NN/40 entries (-N)
```

## Rules

- NEVER remove content without user approval
- ALWAYS present evidence for redundancy claims (which command duplicates it, or why it's trained-in)
- ALWAYS measure before and after — quantify the impact
- ALWAYS update CHANGELOG.md with audit results
- When in doubt about whether something is trained-in, keep it
