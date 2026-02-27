---
name: close-issue
description: Validate acceptance criteria and close an issue with a structured comment
user_invocable: true
---

# /close-issue — Issue Validation & Closure

The quality gate at the end of implementation. Validates that all acceptance criteria are met before closing an issue.

## Task Tracking Mode

When CLAUDE.md defines a Task Tracker section using `tasks/todo.md`:
- **Invocation:** `/close-issue T-1` (uses `T-NN` references)
- **Steps 1-3:** Read task from `tasks/todo.md` Active table; same validation logic
- **Step 4:** Skip (no checkboxes to update on external tracker)
- **Steps 6-7:** Move the row from Active to Done table with completion date; no closing comment needed
- **Step 8:** Check downstream `Blocked by: T-NN` references; remove blocked entries where all blockers are done

## Invocation

```
/close-issue 53         # Close issue #53
/close-issue 53 54 55   # Close multiple issues
```

## Steps

### 1. Fetch the issue

Fetch the issue using the **view issue** operation (see `agent_docs/issue-tracker-ops.md`).

Parse the issue body to extract:
- Summary
- Dependencies (should all be closed by now)
- Acceptance criteria (the `- [ ]` checklist items)
- Any implementation notes

### 2. Validate acceptance criteria

Run the project's validation command (from CLAUDE.md) first — this is the hard gate covering linting, type-checking, and tests. If it fails, stop immediately and return failure.

Then validate each remaining criterion from the issue checklist:

**Automated checks** (run directly):
- File existence checks — verify expected files exist
- Run project-specific checks as defined in CLAUDE.md

**Code-verifiable checks** (inspect the implementation):
- "New module added" — check the module file exists and exports correctly
- "Component renders correctly" — check the component file
- "Service method implemented" — check the service file

**Manual/judgment checks:**
- When called interactively: ask the user to confirm
- When called autonomously (by `/wiggum`): verify by code inspection where possible. If truly unverifiable without a human (e.g., "UI matches design"), mark as SKIP with a note in the closing comment.

Track each criterion as **PASS**, **FAIL**, or **SKIP** (autonomous-only, for criteria requiring human judgment).

### 3. Gate on results

If the validation command failed or ANY acceptance criterion is **FAIL**:
- Do NOT close the issue
- Return a structured failure to the caller:
  ```
  CLOSE_FAILED:
  - Validation: PASS/FAIL (error details if failed)
  - "Criterion text": FAIL — reason
  - "Criterion text": PASS
  ```
- When called by `/wiggum`, this signals the loop to fix and retry

If all criteria are PASS (with optional SKIPs), proceed to close.

### 4. Check off criteria on the issue

Update the issue body to check off each passing criterion:
1. Fetch current body using the **view issue body** operation (see `agent_docs/issue-tracker-ops.md`)
2. Replace `- [ ]` with `- [x]` for each criterion that passed
3. Update using the **edit issue body** operation (see `agent_docs/issue-tracker-ops.md`)

This is best-effort — if it fails, log a warning and continue to close.

### 5. Architecture change detection

Check if the implementation touched architecture-sensitive files as defined in CLAUDE.md. If architecture changed but docs weren't updated, warn:
> "Architecture files changed but docs may not be updated. Continue closing?"

### 6. Compose closing comment

Build a structured comment for the issue:

```markdown
## Closed

### Summary
[Brief description of what was implemented/fixed]

### Changes
- [List of key changes made]
- [Files modified]

### Acceptance Criteria
- [x] Criterion 1 — PASS
- [x] Criterion 2 — PASS
- [x] Validation passes — PASS

### Verification
- Tests: all passing
- Lint: clean
- Type-check: clean
- [Any additional verification notes]
```

### 7. Close the issue

When called interactively, show the closing comment and ask for confirmation.
When called autonomously (e.g., by `/wiggum`), proceed without confirmation:
1. Post the comment using the **comment on issue** operation (see `agent_docs/issue-tracker-ops.md`)
2. Close using the **close issue** operation (see `agent_docs/issue-tracker-ops.md`)

### 8. Downstream impact

After closing, check for downstream effects:

**Unblocked issues:**
- Find all open issues that had `- Blocked by: #NUMBER` in their body
- For each, check if ALL their blockers are now closed
- If fully unblocked, offer to remove the `blocked` label using the **remove label** operation (see `agent_docs/issue-tracker-ops.md`)

**Milestone tracking:**
- If the closed issue belongs to a milestone, check progress using the **check milestone progress** operation (see `agent_docs/issue-tracker-ops.md`)
- Report: "Milestone 'v1.0': 5/12 issues closed (42%)"

### 9. Summary

```
Issue #53 closed.

Newly unblocked:
- #65 — feat(scope): Feature X (was blocked by #53, #54, #55)
  -> Still blocked by #54, #55
- #70 — feat(scope): Feature Y
  -> Now fully unblocked! Removed `blocked` label.

Milestone: v1.0 — 5/12 closed (42%)
```

## Rules

- NEVER close an issue if the project's validation command fails
- NEVER close an issue if any acceptance criterion is FAIL — return structured failure to the caller
- NEVER close without user confirmation (unless running autonomously within /wiggum)
- ALWAYS post a structured closing comment
- ALWAYS check off passing criteria on the issue body before closing
- If multiple issues are provided, process them sequentially — each must pass independently
- If an issue has no acceptance criteria, warn the user and ask if they want to close anyway
