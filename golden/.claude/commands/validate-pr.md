---
name: validate-pr
description: Validate a release PR — run /review-pr, post findings, create issues for FAIL/WARN findings, and return a structured result
user_invocable: true
---

# /validate-pr — Release PR Validation

Runs a full quality review on a release PR, posts findings as a PR comment (audit trail), creates issues for any FAIL or WARN findings, and returns a structured result. Designed as the integration quality gate before a release PR is marked ready for review.

## Invocation

```
/validate-pr 95
```

**Autonomy:** When called from another skill (e.g., `/wiggum`), this skill runs autonomously — no confirmation prompts. When invoked directly by a user, it asks for confirmation before posting comments and creating issues.

## Steps

### 1. Resolve PR context

Fetch the PR details:

```bash
gh pr view NUMBER --json number,title,body,baseRefName,headRefName,milestone,labels,isDraft
```

Extract:
- **PR_NUMBER**: the PR number
- **MILESTONE**: the milestone title (if any)
- **BASE_BRANCH**: the base branch (should be `main` for a release PR)
- **HEAD_BRANCH**: the head branch (should be `release/*`)

If the PR has no milestone, WARN but continue — issues created later will have no milestone assigned.

### 2. Count previous laps

Search PR comments for the `<!-- validate-pr-lap -->` HTML marker:

```bash
gh api repos/{owner}/{repo}/issues/{PR_NUMBER}/comments --jq '[.[] | select(.body | contains("<!-- validate-pr-lap -->"))] | length'
```

Store the count as `PREVIOUS_LAPS`. The current run is lap `PREVIOUS_LAPS + 1`.

If `PREVIOUS_LAPS >= 3`, enter **max-laps mode**: the review will still run, findings will still be posted and have issues created, but the result will be MAX_LAPS so wiggum does not restart the loop. This is the escape hatch to prevent infinite loops.

### 3. Run review

Execute the full `/review-pr` logic against the PR. **Always run with full build gates** (never `--diff-only`). This is the integration quality check — it catches issues that individual validation runs during implementation missed:

- Conflicting migrations between features
- Import collisions
- Holistic update gaps across multiple features
- Anti-patterns introduced by the combination of changes

Run all review sections defined in `/review-pr`. Collect findings with their severity (PASS, WARN, FAIL) and the overall verdict.

### 4. Post review as PR comment

Post the review as a **regular PR comment** (not a review action). This avoids triggering GitHub's review state machine and keeps the audit trail clean.

Format the comment:

```markdown
<!-- validate-pr-lap -->
## Validation Lap {LAP_NUMBER}: PR #{PR_NUMBER}

### Verdict: {APPROVE | REQUEST_CHANGES}

### Summary
[2-3 sentence assessment of the release PR state]

### Findings
[All review section findings with PASS/WARN/FAIL verdicts]

### Action Items
[Numbered list of FAIL and WARN findings that require fixes]
```

The `<!-- validate-pr-lap -->` HTML comment at the top is the marker used for lap counting in step 2.

Post using the **comment on issue** operation (see `agent_docs/issue-tracker-ops.md`). Use `gh issue comment` (not `gh pr review`) to post as a regular comment.

When invoked directly by a user, ask before posting: "Post this validation comment on PR #NN?"
When called from another skill, post without asking.

### 5. Evaluate

Determine the result based on the review verdict and lap count:

| Condition | Result |
|-----------|--------|
| Zero FAIL and zero WARN findings | **PASS** |
| FAIL or WARN findings exist AND current lap < 3 | **ISSUES_CREATED** (proceed to step 6) |
| FAIL or WARN findings exist AND current lap >= 3 | **MAX_LAPS** (proceed to step 6 — issues are still created, but wiggum will not restart the loop) |

### 6. Verify and create issues

Reached when result is **ISSUES_CREATED** or **MAX_LAPS** (issues are always created when findings exist — MAX_LAPS only changes whether wiggum restarts the loop).

#### Verify findings

Before creating issues, verify each FAIL and WARN finding is genuine — not a false positive:

- **Read the actual source files** referenced in the finding, not just the diff. Confirm the problem exists in the current code on the release branch
- **Check context**: a finding may look like an anti-pattern in isolation but be correct in context
- **Build gate failures**: re-run the failing command to confirm it's reproducible, not a flaky test or transient environment issue
- **Downgrade or dismiss** findings that don't hold up on inspection. Update the posted comment if any findings were dismissed after verification

Only verified findings proceed to issue creation.

#### Fix PR metadata inline

**PR metadata findings (section 1) are fixed inline** — use `gh pr edit` to fix title/description/labels issues directly rather than creating issues for them.

#### Create issues

**First, survey existing issues** to avoid duplicates:

Fetch open issues using the **list open issues** operation (see `agent_docs/issue-tracker-ops.md`).

For each verified FAIL or WARN finding that doesn't duplicate an existing issue, create using the **create issue** operation (see `agent_docs/issue-tracker-ops.md`):

Issue body follows the standardized format (see `agent_docs/issue-conventions.md`):
```markdown
## Summary
[Description of the finding from the review]

Found during validation lap {LAP_NUMBER} of PR #{PR_NUMBER}.
Severity: {FAIL|WARN}

## Dependencies
None

## Acceptance Criteria
- [ ] [Specific fix criterion based on the finding]
- [ ] Validation passes

## Implementation Notes
- Source: PR #{PR_NUMBER} validation lap {LAP_NUMBER}
- Review comment: [link to the validation comment]
- [Relevant file paths and line numbers from the finding]
```

Rules for issue creation:
- Both FAIL and WARN findings become issues
- Title includes `(PR #NN validation)` so the issue appears in the PR timeline
- Assign to the same milestone as the PR (if any)
- Apply appropriate labels based on the finding scope
- When invoked directly by a user, present issues for review before creating
- When called from another skill, create without asking

### 7. Return structured result

Report the outcome clearly:

**PASS:**
```
## Validation Result: PASS

PR #{PR_NUMBER} passed all quality checks on lap {LAP_NUMBER}.
Ready to finalize.
```

**ISSUES_CREATED:**
```
## Validation Result: ISSUES_CREATED

PR #{PR_NUMBER} — lap {LAP_NUMBER} found {N} findings ({F} FAIL, {W} WARN).
Created issues: #AA, #BB, #CC
These must be resolved before the release can proceed.
```

**MAX_LAPS:**
```
## Validation Result: MAX_LAPS

PR #{PR_NUMBER} has reached {LAP_NUMBER} validation laps.
Created issues: #AA, #BB, #CC
Remaining findings are documented in PR comments for human review.
Escalating to human reviewer — wiggum will not restart the loop.
```

## Rules

- ALWAYS run full build gates — this is the integration quality check, never use `--diff-only`
- ALWAYS post as a PR comment (`gh issue comment`), never as a review action (`gh pr review`)
- ALWAYS include the `<!-- validate-pr-lap -->` marker in the comment for lap counting
- Both FAIL and WARN findings become issues — only PASS findings are skipped
- ALWAYS verify findings against actual source code before creating issues — dismiss false positives
- Fix PR metadata findings (section 1) inline via `gh pr edit`, not as issues
- On lap 3+, still create issues for new findings, but return MAX_LAPS so wiggum does not restart the loop
- Check for duplicate issues before creating (survey existing issues first)
- Do NOT run concurrently on the same PR — one validation at a time
- When called from another skill, run autonomously (no confirmation prompts). When invoked directly by a user, ask before posting and creating issues
