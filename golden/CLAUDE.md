# Project Configuration

> This file defines how Claude operates in this project. The baseline sections are universal.
> Project-specific sections are appended below the bootstrap marker by `/bootstrap-claude`.

## Development Philosophy

- **Test-Driven Development (TDD):** Always write tests before implementation.
  1. Write test file first with test cases for happy path and key error cases
  2. Run tests — confirm new tests fail (red)
  3. Implement the production code
  4. Run tests — confirm all tests pass (green)
  5. Refactor if needed
- **Issue-Driven Workflow:** All work is tracked via the project's issue tracker. Never create tracking markdown files in the repository — use issues, milestones, and project boards instead.
- **Validate Before Claiming Completion:** Always run the project's validation command before committing, closing issues, or claiming work is done. Never skip validation.
- **YAGNI:** Don't over-engineer. Only build what's needed now. Three similar lines of code is better than a premature abstraction.
- **DRY within reason:** Avoid duplication, but don't create abstractions for one-time operations.

## Issue Management

All work is tracked via the project's issue tracker with structured metadata.

**Issue format:**
```
Title: {type}({scope}): {description}

Types: feat | fix | refactor | docs | discovery | design | infra
Scopes: defined per-project (see Project-Specific Configuration below)
```

**Issue body structure:**
```
## Summary
[1-3 sentences describing what and why]

## Dependencies
- Blocked by: #NN — [reason]
- Part of: #EPIC — [epic title]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]
- [ ] Validation passes

## Implementation Notes
[Key files, approach, constraints]
```

**Dependency format (canonical — the ONLY recognized format):**
```
- Blocked by: #NN — reason
```
`#NN` uses the configured issue reference format (see Issue Tracker section). Other patterns (`depends on`, `waiting on`, `after #NN`) are NOT recognized by automation.

## Issue Tracker

> Configured by `/bootstrap-claude`. Default: GitHub Issues (`gh` CLI).
> To use a different tracker (Jira, Linear, etc.), update this section
> and the corresponding permissions in settings.local.json.

**Tool:** GitHub CLI (`gh`)
**Issue reference format:** `#NN` (e.g., `#53`)
**Smart close syntax:** `Closes #NN`
**Dependency format:** `- Blocked by: #NN — reason`

### Operations Reference

| Operation | Command |
|-----------|---------|
| List open issues | `gh issue list --state open --limit 200 --json number,title,body,labels,milestone,assignees` |
| View issue | `gh issue view NUMBER --json number,title,body,labels,milestone,assignees` |
| View issue body | `gh issue view NUMBER --json body --jq '.body'` |
| Create issue | `gh issue create --title "TITLE" --body "BODY" --label "LABEL" [--assignee "USER"]` |
| Edit issue body | `gh issue edit NUMBER --body "BODY"` |
| Close issue | `gh issue close NUMBER` |
| Comment on issue | `gh issue comment NUMBER --body "COMMENT"` |
| Add label | `gh issue edit NUMBER --add-label "LABEL"` |
| Remove label | `gh issue edit NUMBER --remove-label "LABEL"` |
| Assign to milestone | `gh issue edit NUMBER --milestone "NAME"` |
| Create milestone | `gh api repos/{owner}/{repo}/milestones --method POST -f title="NAME" -f state="open"` |
| List milestones | `gh api repos/{owner}/{repo}/milestones` |
| Check milestone progress | `gh api repos/{owner}/{repo}/milestones/{number}` |
| Resolve current user | `gh api user --jq '.login'` |
| List collaborators | `gh api repos/{owner}/{repo}/collaborators --jq '.[].login'` |

## Commit Conventions

Use conventional commits format:
```
type(scope): description

- Bullet point 1
- Bullet point 2

Closes #NN
```

- Types: `feat`, `fix`, `refactor`, `docs`, `discovery`, `design`, `infra`
- Include the smart close syntax (see Issue Tracker section) to auto-close the linked issue when merged
- List key changes in the body
- Never force-push or rewrite history on shared branches

## PR Workflow

- Every change gets a pull request
- PRs link to issues via the smart close syntax (see Issue Tracker section) in the body
- Feature branches target the release branch (if one exists), otherwise `main`
- Branch naming: `{issue-number}-{slug}` (e.g., `53-add-auth-service`)
- Use `/review-pr` before merging
- One issue per feature branch — don't bundle unrelated work

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/wiggum` | Automated dev loop — pick next unblocked issue, implement, test, close, repeat |
| `/triage` | Analyze backlog — dependency graph, readiness, label validation |
| `/create-issues` | Convert a plan into structured issues with tracking epic |
| `/close-issue` | Validate acceptance criteria and close an issue with structured comment |
| `/review-pr` | Standardized PR review against project quality standards |
| `/setup-release` | Plan a release — milestone, branch, implementation order |
| `/bootstrap-claude` | Adapt this configuration to the current project's tech stack |

## Code Quality

- Run the project validation command before every commit
- Follow existing project conventions — don't introduce new patterns without discussion
- No hardcoded values that should be configuration
- Error handling at system boundaries
- No committed credentials, secrets, or .env files
- Tests exist for new functionality

## Pre-existing Failures

If a test file you did NOT modify is failing, the failure is pre-existing. Create an issue for it (if one doesn't already exist) using the **create issue** operation (CLAUDE.md § Issue Tracker) and continue — do not silently work around it.

<!-- bootstrap-claude: project-specific below -->
<!-- Everything below this line is generated by /bootstrap-claude for this specific project -->
<!-- To regenerate: delete everything below this marker and run /bootstrap-claude again -->
