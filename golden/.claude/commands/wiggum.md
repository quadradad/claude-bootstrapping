---
name: wiggum
description: Automated dev loop — pick the next unblocked issue, implement, test, close, and repeat
user_invocable: true
---

# /wiggum — Automated Development Loop

The orchestrator. Picks up issues in dependency order and implements them continuously until the release is complete.

## Invocation

```
/wiggum                        # Auto-detect release branch + milestone
/wiggum release/v1.0           # Target a specific release
/wiggum 53                     # Start with a specific issue
```

## Task Tracking Mode

When CLAUDE.md defines a Task Tracker section using `tasks/todo.md`:
- **Step 1 (Context):** Read `tasks/todo.md` Active table instead of querying milestones. Skip release PR discovery.
- **Step 2 (Select):** Pick the highest-impact unblocked task from the Active table
- **Step 3 (Branch):** Use `T-NN-slug` branch naming (e.g., `T-3-add-auth`)
- **Step 8 (Commit):** Use `Completes T-NN` instead of the smart close syntax
- **Step 9 (PR):** Target `main` (no release branch in todo.md mode)
- **Step 10 (Close):** Run `/close-issue T-NN` to move the task to Done
- **Step 11 (Merge):** Skip release PR checklist update
- **Release Completion:** Not applicable — loop ends when the Active table is empty

## Loop

Each iteration follows this sequence:

### 1. Context

Detect the current working context:
- Check the current git branch — if on a `release/*` branch, use its milestone
- If on `main` or a feature branch, use the most recent open milestone
- If a specific issue number was provided, start with that issue

```bash
git branch --show-current
```

Check the milestone using the **list milestones** operation (see `agent_docs/issue-tracker-ops.md`), filtering for the target milestone.

**Discover release PR:**
Find the open draft PR from the release branch to main:
```bash
gh pr list --base main --head release/RELEASE_NAME --state open --json number,isDraft --jq '.[0].number'
```
Store the result as RELEASE_PR_NUMBER. If no draft PR is found, proceed without PR checklist updates.

### 2. Select next issue

Find the highest-impact unblocked issue in the milestone:
- Fetch all open issues in the milestone
- Run dependency analysis (triage logic)
- Filter to ready (unblocked) issues only
- Sort by impact score (issues that unblock the most others first)
- Pick the top issue and proceed immediately

### 3. Branch

Create a feature branch from the release branch:

```bash
git checkout release/RELEASE_NAME
git pull origin release/RELEASE_NAME
git checkout -b 53-database-service
```

Branch naming: `{issue-number}-{slug}` where slug is a short kebab-case summary derived from the issue title.

### 4. Understand

Before implementing, understand the issue:

**For bugs:**
- Read the issue description for reproduction steps
- Attempt to reproduce the bug
- If reproduced, proceed to fix
- If not reproducible, skip the issue (log it in the closing comment) and move to the next one

**For features:**
- Read the issue description, acceptance criteria, and implementation notes
- Review relevant existing code and architecture docs referenced in CLAUDE.md
- Check shared types, existing modules, and established patterns
- Proceed to implementation

### 5. Implement

Follow the project's architecture strictly as defined in CLAUDE.md.

**Test-Driven Development (all changes):**
1. Write test file first with test cases covering the happy path and key error cases
2. Run the project's test command — confirm the new tests fail (red)
3. Implement the production code
4. Run the project's test command — confirm all tests pass (green)
5. Refactor if needed

**For all changes:**
- Follow CLAUDE.md coding rules and conventions
- Shared types belong in the location defined by the project — never duplicate types across boundaries
- Use the project's standard tooling commands, never raw commands

### 6. Validate

Run the full validation suite — this is a **hard gate**:

```bash
# Run the project's validation command (defined in CLAUDE.md)
```

This runs the project's linting, type-checking, and all tests.

**Retry logic:**
- If validation fails, analyze the error and fix
- Re-run after each fix
- After 2 consecutive failures on the same issue, STOP — do not attempt a third fix with the same approach:
  - Re-read the issue requirements and your implementation from scratch
  - Ask: is the approach itself wrong, or just the execution?
  - If the approach is wrong: revert to the branch point and re-implement with a different strategy
  - If the execution has a fixable bug: proceed with one final attempt
- If still failing after 3 total attempts, revert the branch changes, log the failure as a comment on the issue, skip to the next issue, and continue the loop

**Pre-existing failures:** If a test file that you did NOT modify is failing, the failure is pre-existing. Create an issue for it using the **create issue** operation (see `agent_docs/issue-tracker-ops.md`) if one doesn't already exist, and continue — do not silently work around it.

### 6b. Post-Retry Reflection

If this issue required 2+ retry attempts before passing validation:

1. Run `/pomo` with context about the retry failures:
   - What went wrong on each attempt
   - The approach tried and why it failed
   - What finally worked (or didn't)
2. Continue the loop regardless of `/pomo`'s outcome — this is non-blocking

This captures debugging patterns while they're fresh, feeding the self-improvement loop.

### 7. Docs

Check if the implementation requires documentation updates per the project's conventions in CLAUDE.md. Update relevant docs if architecture, APIs, or data models changed.

If no documentation updates are needed, skip this step.

### 8. Commit & Push

Stage and commit with a descriptive message:

```bash
git add [specific files]
git commit -m "feat(scope): implement feature X

- Key change 1
- Key change 2
- Key change 3

SMART_CLOSE_SYNTAX"
git push -u origin 11-feature-branch
```

Commit message rules:
- Use conventional commits format matching the issue title type
- Include the smart close syntax (see `agent_docs/issue-tracker-ops.md`) to auto-close the issue when merged
- List key changes in the body

### 9. PR

Create a pull request targeting the release branch:

```bash
gh pr create \
  --base release/RELEASE_NAME \
  --title "feat(scope): Implement feature X (#11)" \
  --body "PR_BODY"
```

PR body:
```markdown
## Description
[Summary from the issue]

## Changes
- [Key changes made]

## Testing
- [x] Validation passes

## Checklist
- [x] Architecture conventions respected
- [x] Shared types updated where needed
- [x] Tests added
- [x] All tests pass locally

SMART_CLOSE_SYNTAX
```

Use the smart close syntax from `agent_docs/issue-tracker-ops.md` for the linked issue reference.

### 10. Close issue

Run `/close-issue` to validate acceptance criteria and close:
- Runs the project's validation command (hard gate)
- Validates each acceptance criterion against the implementation
- If all pass: checks off criteria on the issue, posts closing comment, closes the issue, updates downstream labels

**If close-issue returns failure:**
1. Analyze the failed criteria — these are unmet acceptance requirements
2. Fix the implementation to satisfy the failing criteria
3. Commit the fix, push, and update the PR
4. Retry `/close-issue` (maximum 2 retries — shares the step 6 retry budget)
5. If still failing after retries, treat as a validation failure: revert, log, skip, continue loop

### 11. Merge

Merge the PR into the release branch immediately:

```bash
gh pr merge PR_NUMBER --merge --delete-branch
git checkout release/RELEASE_NAME
git pull origin release/RELEASE_NAME
```

**Update release PR checklist:**
If RELEASE_PR_NUMBER is set, check off the completed issue in the draft PR body:
1. Fetch current body: `gh pr view RELEASE_PR_NUMBER --json body --jq '.body'`
2. Replace `- [ ] #NN —` with `- [x] #NN —` for the just-closed issue number
3. Update: `gh pr edit RELEASE_PR_NUMBER --body "UPDATED_BODY"`

This is best-effort — if it fails, log a warning and continue the loop.

### 12. Loop

After merging, immediately continue:
- Log a summary of what was completed
- Check milestone progress
- Select the next highest-impact unblocked issue
- Continue the loop without pausing

## Release Completion

When all milestone issues are closed:
1. Run final validation using the project's validation command (from CLAUDE.md)
2. Finalize the draft PR — update the body with completion status:
   ```bash
   gh pr view RELEASE_PR_NUMBER --json body --jq '.body'
   gh pr edit RELEASE_PR_NUMBER --body "FINAL_BODY"
   ```
3. Mark the draft PR ready for review:
   ```bash
   gh pr ready RELEASE_PR_NUMBER
   ```
   Do NOT auto-merge to main — leave this for the user.
4. Report:
   ```
   ## Release Complete!

   Milestone: v1.0 — 12/12 closed (100%)
   PR to main: #30 (ready for review)

   All issues implemented, tested, and merged to release branch.
   Review and merge PR #30 when ready.
   ```

## Discovery Escape Hatch

If during implementation you discover:
- A bug that needs fixing before you can continue
- Missing functionality that should be a separate issue
- A dependency that wasn't captured in the original plan

**Handle autonomously:**
1. Create new issue(s) using `/create-issues` format
2. Add them to the milestone and update the dependency graph
3. If the new issue blocks the current work, commit progress so far, skip the current issue, and pick up the new blocker issue next
4. If the new issue is independent, continue with the current work and let the new issue get picked up in a future iteration

## Autonomy & Stopping Conditions

The loop is fully autonomous — no user interaction required. It runs until one of these conditions is met:
- All milestone issues are closed (release complete — draft PR marked ready for review)
- All remaining issues are blocked or were skipped due to failures
- A dependency cycle is detected
- The user intervenes

Individual issue failures (test gate, unreproducible bugs) are logged and skipped, not terminal. The loop continues with the next available issue.

## Rules

- ALWAYS follow the project's architecture rules defined in CLAUDE.md
- ALWAYS use the project's standard tooling commands, never raw commands
- NEVER force-push or rewrite history
- NEVER skip validation — the project's validation command is the hard gate
- Feature branches target the release branch, not `main`
- One issue per feature branch — don't bundle unrelated work
- ALWAYS practice TDD — write test files before implementation code
- ALWAYS use the project's validation command as the pre-commit gate
- If pre-existing tests are broken, create an issue — do NOT silently ignore them
- The release draft PR is created by /setup-release and promoted to ready-for-review at completion — never create a second PR to main
