# Golden Set Changelog

## 2026-02-27 — v2.0 Restructuring

### Added
- agent_docs/issue-conventions.md (Level 1) — extracted from CLAUDE.md
- agent_docs/issue-tracker-ops.md (Level 1) — extracted from CLAUDE.md
- agent_docs/self-improvement.md (Level 1) — consolidated from CLAUDE.md + /pomo + /review-pr
- BUDGETS.md — context budget constraints for auto-loading files
- CHANGELOG.md — sync system observability
- /slim command — golden set audit and compression

### Restructured
- CLAUDE.md baseline: 174 lines → ~55 lines (reference data moved to agent_docs/)
- /improve-golden-set: added budget enforcement, classification, extraction gravity
- /update-claude: added post-application budget audit, agent_docs awareness
- /bootstrap-claude: added content classification and budget checks
- /wiggum: integrated /pomo trigger on retry failures
- /review-pr: unified self-improvement via /pomo
- /pomo: added lessons lifecycle management

### Removed from CLAUDE.md
- Workflow Commands table (redundant — Claude Code discovers commands)
- Operations Reference table (moved to agent_docs/issue-tracker-ops.md)
- Issue format specs (moved to agent_docs/issue-conventions.md)
- Continuous Improvement format spec (moved to agent_docs/self-improvement.md)
- YAGNI instruction (trained-in model behavior)
- DRY instruction (trained-in model behavior)
- Code Quality section (mostly trained-in, validation gate covered elsewhere)

### Budget impact
- CLAUDE.md baseline: 174 → ~55 lines (~20 instructions)
- agent_docs/: 0 → 3 files

> Note: Line counts are estimates — finalized in Phase 7 (issue #54).
