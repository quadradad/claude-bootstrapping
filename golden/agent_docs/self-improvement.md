# Self-Improvement System

> Reference document. Loaded by /pomo, /review-pr, and /wiggum when updating lessons.
> Not read every session — see CLAUDE.md for behavioral instructions.

## Lessons Format

Each entry in `.claude/lessons.md` follows this format:

```markdown
### [Pattern name]
- **Wrong:** [what was done incorrectly]
- **Right:** [the correct approach]
- **Why:** [root cause or reasoning]
```

Guidelines:
- Rules should be **generalizable** — not specific to one incident
- Include a code example only if it makes the rule significantly clearer
- Keep each lesson concise

## Triggers

Update `.claude/lessons.md` when:
- After **any user correction** — capture what went wrong and the better approach
- After **/review-pr** finds issues Claude introduced — reflect on why
- After **/wiggum** retry failures (2+ attempts before validation passes)
- Ruthlessly deduplicate — update existing entries rather than adding redundant ones

**/pomo is the primary entry point for all self-improvement.** Commands invoke
/pomo rather than doing inline reflection. /pomo handles evaluation, deduplication,
format compliance, and lifecycle management.

## Deduplication Rules

Before writing a new lesson:
1. Read `.claude/lessons.md` and check for existing coverage
2. **Same pattern, new example:** Update the existing lesson's incident count. Don't create a duplicate.
3. **Related but distinct:** Create a new lesson and cross-reference the related one.

## Lesson Lifecycle

Every lesson has an implicit lifecycle:

1. **Active** — Recently captured, not yet proven across multiple incidents.
   New lessons are Active by default (no explicit tag needed).
2. **Validated** — Confirmed by recurrence (2+ incidents match this pattern).
   When /pomo finds a 2nd+ matching incident, update the existing lesson
   and mark it Validated.
3. **Promoted** — Encoded into CLAUDE.md or a command as a permanent rule.
   Remove from lessons.md after promotion with a note:
   "Promoted to CLAUDE.md § [section]" or "Promoted to /command-name".
4. **Stale** — No matching incidents in 30+ days of active development.
   Candidate for archival.

## Pruning Rules

Enforced by /slim and /pomo:

- **Max entries:** 40 active lessons in `.claude/lessons.md`
- **Promotion:** When a lesson has been validated 3+ times, consider promoting
  it to a CLAUDE.md instruction or command rule. After promotion, remove from
  lessons.md.
- **Archival:** Lessons older than 60 days with no new matching incidents
  move to `.claude/lessons-archive.md`. They're still searchable but don't
  load at session start.
- **Deduplication:** Always merge rather than creating a second entry for
  the same pattern. Update the existing entry's incident count.
