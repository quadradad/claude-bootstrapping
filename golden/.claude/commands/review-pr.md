---
name: review-pr
description: Review a pull request against project quality standards — consistent checks regardless of who invokes it
user_invocable: true
---

# /review-pr — Standardized Pull Request Review

Performs a repeatable, consistent review of a PR against the project's quality standards. Every invocation checks the same things in the same order, producing a structured verdict.

## Invocation

```
/review-pr 42              # Review PR #42
/review-pr 42 --diff-only  # Skip build/test gates, review code only
```

## Review Sections

The review proceeds through 7 sections. Each produces PASS, WARN, or FAIL findings. The final verdict is based on the aggregate.

---

### 1. PR Metadata

Fetch the PR and its linked issue:

```bash
gh pr view NUMBER --json number,title,body,baseRefName,headRefName,files,additions,deletions,labels,milestone
gh pr diff NUMBER
```

Check:
- [ ] **Title** follows conventional format: `type(scope): description` or is descriptive
- [ ] **Description** is filled in (not just template boilerplate)
- [ ] **Linked issue** exists (smart close syntax from `agent_docs/issue-tracker-ops.md` in body) — WARN if missing, not FAIL
- [ ] **Base branch** is correct (release branch if one exists, otherwise `main`)

### 2. Architecture Compliance

Scan the diff for violations of the project's architecture rules defined in CLAUDE.md. These are **FAIL** findings.

Check for:
- **Layer boundary violations**: Code that crosses architectural layers inappropriately (e.g., UI code directly accessing data layer, bypassing service abstractions)
- **Import restriction violations**: Imports that break the project's module boundary rules (e.g., importing internal modules from the wrong layer)
- **Data access convention bypasses**: Code that circumvents the project's established patterns for data access or communication between layers
- **Missing wiring for new abstractions**: New interfaces, channels, or contracts introduced in one layer but not properly registered or connected in other required layers

### 3. Holistic Update Check

If shared types, interfaces, or contracts changed, verify all consuming layers were updated:

- [ ] Type definitions
- [ ] Implementations
- [ ] Wiring/registration
- [ ] Consumers
- [ ] Tests

WARN if a layer is missing — the author may have intentionally split the work across PRs, but it should be called out.

### 4. Code Quality

Scan changed files for quality issues:

- [ ] Error handling at boundaries — services catch and translate errors to human-readable messages
- [ ] No hardcoded values that should be config
- [ ] Proper types — no unjustified `any` or equivalent
- [ ] No `.env` files in the diff
- [ ] No `console.log` left in production code (WARN)
- [ ] File names follow project conventions

### 5. Test Coverage

Check that the PR includes appropriate tests:

- [ ] **New functionality** has tests
- [ ] **Bug fixes** include regression tests
- [ ] **Test files** are in the correct location per project conventions

Assess based on what changed:
- Service added — expect service test: WARN if missing
- Utility function added — expect unit test: WARN if missing
- Component added — expect component test for non-trivial components: WARN if missing
- Pure refactor with no behavior change — tests optional

### 6. Security

Scan for security issues:

- [ ] **No committed secrets or credentials** in the diff
- [ ] **No injection vulnerabilities** — parameterized queries, no string concatenation for commands or queries
- [ ] **External inputs validated** — user input, API responses, file contents validated before use
- [ ] **Sensitive data handled appropriately** — tokens not logged, credentials stored securely

### 7. Build Gates

Unless `--diff-only` was specified, run the hard gates:

```bash
# Run the project's validation command (from CLAUDE.md)
```

This runs the project's linting, type-checking, and all tests.

- Passes — PASS
- Fails — FAIL (show error output)

---

## Output Format

Produce a structured review comment. Post it on the PR.

```markdown
## PR Review: #{number} — {title}

### Verdict: {APPROVE | REQUEST_CHANGES | COMMENT}

### Summary
[2-3 sentence overall assessment]

### Findings

#### {PASS|WARN|FAIL} 1. PR Metadata
- {status} Title follows convention
- {status} Description filled in
- {status} Linked issue present
[...etc]

#### {PASS|WARN|FAIL} 2. Architecture Compliance
[findings or "No architecture violations detected"]

#### {PASS|WARN|FAIL} 3. Holistic Update Check
[findings or "N/A — no shared type changes"]

#### {PASS|WARN|FAIL} 4. Code Quality
[findings]

#### {PASS|WARN|FAIL} 5. Test Coverage
[findings]

#### {PASS|WARN|FAIL} 6. Security
[findings or "No security issues found"]

#### {PASS|WARN|FAIL} 7. Build Gates
- Validate: {PASS|FAIL}
[or "Skipped (--diff-only)"]

### Action Items
[Numbered list of things that must be fixed before merge, if any]
```

### Verdict Rules

- **APPROVE**: Zero FAILs, at most minor WARNs
- **REQUEST_CHANGES**: Any FAIL finding, or multiple significant WARNs
- **COMMENT**: No FAILs but notable WARNs worth discussing

### Posting the Review

Ask the user before posting:
> "Post this review as a comment on PR #NN?"

If confirmed:
```bash
gh pr review NUMBER --comment --body "REVIEW_BODY"
```

For REQUEST_CHANGES, use:
```bash
gh pr review NUMBER --request-changes --body "REVIEW_BODY"
```

For APPROVE with no issues:
```bash
gh pr review NUMBER --approve --body "REVIEW_BODY"
```

### 8. Self-Improvement Reflection

If the verdict is REQUEST_CHANGES or 2+ significant WARNs, **and** the PR was authored by Claude:

Run `/pomo` with the review findings as context. /pomo handles pattern identification, deduplication, and lessons.md updates per `agent_docs/self-improvement.md`.

Skip this step for PRs not authored by Claude.

## Rules

- NEVER approve a PR that has FAIL findings
- NEVER skip a section — every section gets evaluated (use N/A if not applicable)
- ALWAYS show the same sections in the same order for consistency
- Check the diff, not just file names — understand what actually changed
- Be specific in findings — reference file paths and line numbers from the diff
- Distinguish between project convention violations (FAIL) and suggestions (WARN)
