# Context Budget Constraints

These budgets are enforced by /improve-golden-set, /update-claude, /bootstrap-claude, and /slim.
Exceeding a budget requires explicit user override with justification.

| File | Max Lines | Max Instructions | Rationale |
|------|-----------|-----------------|-----------|
| CLAUDE.md (baseline, above marker) | 60 | 25 | ~35% of model instruction capacity |
| CLAUDE.md (project-specific, below marker) | 80 | 30 | Combined with baseline stays under 55% |
| agent_docs/* (each file) | 120 | — | Reference data, not instructions |
| .claude/lessons.md | 40 entries | — | Pruned to highest-value patterns |
| settings.local.json (allow array) | 100 entries | — | Permission bloat slows startup |

## What counts as an "instruction"

An instruction is a directive that changes Claude's behavior. These count:
- **Imperatives:** "Always X", "Never Y", "Use Z"
- **Conditionals:** "If X, then Y"
- **Constraints:** "No more than N", "Only when X"
- **Format specs:** "Title format: type(scope): description"

These do **NOT** count:
- Descriptive text: "This file defines how Claude operates"
- Pointers: "See agent_docs/foo.md for details"
- Section headers
- Code examples within reference docs
