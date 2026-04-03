---
name: create-issues
description: Create issues from a plan discussed in conversation — with tracking epic, dependencies, and assignee resolution
user_invocable: true
---

# /create-issues — Plan-to-Issues Pipeline

Convert a plan discussed in conversation into a structured set of issues with a tracking epic, explicit dependencies, and proper sequencing.

## Task Tracking Mode

When CLAUDE.md defines a Task Tracker section using `tasks/todo.md`:
- **Step 0:** Skip assignee resolution — assignees are not available in todo.md mode
- **Steps 1-5:** Same planning and validation logic
- **Step 6:** Present the same review table, using `T-NN` IDs instead of `#NN`
- **Step 7:** Add rows to the Active table in `tasks/todo.md` with auto-incremented `T-NN` IDs. No labels.
- **Step 8:** Validate by re-reading the file

## Plan Mode

**Enter plan mode now** (before Step 1). Steps 1–5 run in plan mode — reason through the full issue structure before any GitHub API calls. Exit plan mode before Step 7 (issue creation).

This ensures high-quality planning before execution.

## Invocation

```
/create-issues                  # No assignee — issues created unassigned
/create-issues me               # Assign to the authenticated user
/create-issues ben              # Resolve "ben" to a collaborator username
/create-issues bnsmcx           # Exact username also works
```

The argument is always an **assignee** — a conversational name, username, or `me`.

## Step 0. Resolve Assignee

If an assignee argument was provided:

1. **`me`** — Resolve using the **resolve current user** operation (see `agent_docs/issue-tracker-ops.md`). Use the returned login.

2. **Any other name** — Resolve to a username:
   a. Fetch collaborators using the **list collaborators** operation (see `agent_docs/issue-tracker-ops.md`)
   b. Try to match the argument (case-insensitive) against:
      - Exact `login` match
      - Partial `login` match (argument is a prefix or substring)
      - Display `name` match (first name, last name, or full name)
   c. If exactly one match — use it
   d. If multiple matches — present the options and ask the user to pick
   e. If no match — ask the user: "I couldn't find a collaborator matching '{name}'. What's their username?"

3. **No argument** — Leave issues unassigned.

Store the resolved username as `$ASSIGNEE` for use in Step 7.

## Step 1. Extract Plan from Conversation

Look back through the conversation for the plan that was discussed. The plan may exist as:
- A numbered list of steps discussed before entering plan mode
- A plan written during plan mode (the most recent plan)
- A bullet-point breakdown of features or tasks

Extract:
- **Epic title**: The overall goal or feature name
- **Steps**: Each discrete unit of work, preserving the original sequence
- **Implementation details**: Any specifics mentioned (files to touch, approaches, constraints)
- **Dependencies**: Any ordering or blocking relationships discussed

If no plan is found in conversation, ask: "I don't see a plan in our conversation. Could you describe what issues you'd like to create?"

If the plan exists but has unresolved questions, open decisions, or vague scope — stop and suggest: "This plan has open questions that could lead to poorly scoped issues. Run `/grill-me` first to resolve them, then re-run `/create-issues`."

## Step 2. Survey Existing Issues

Fetch all open issues using the **list open issues** operation (see `agent_docs/issue-tracker-ops.md`).

Build a set of existing issue titles and key terms to detect potential duplicates.

## Step 3. Draft the Tracking Epic

Create a tracking issue that encapsulates the entire plan:

**Title:** `tracking: {epic title}`

**Body:**
```markdown
## Summary
{1-3 sentences describing the overall goal from the plan}

## Issues

This epic tracks the following implementation sequence:

| Order | Issue | Status |
|-------|-------|--------|
| 1 | {new-1 title} | :white_circle: |
| 2 | {new-2 title} | :white_circle: |
| ... | ... | ... |

## Sequence & Dependencies
{Mermaid diagram or text description showing the dependency graph}

## Acceptance Criteria
- [ ] All child issues closed
- [ ] Validation passes
```

**Labels:** `tracking`

## Step 4. Draft Child Issues

For each step in the plan, create one issue. Follow this format exactly:

**Title:** `{type}({scope}): {description}`
- type: `feat` | `fix` | `refactor` | `docs` | `discovery` | `design` | `infra`
- scope: Use project-specific scopes defined in CLAUDE.md, or omit for cross-cutting changes

**Body:**
```markdown
## Summary
[1-3 sentences describing what and why — pull details from the plan discussion]

## Dependencies
- Blocked by: #NN — [reason]
- Part of: #EPIC — [epic title]
(or "None" for the first issue in the sequence, but always include "Part of")

## Acceptance Criteria
- [ ] [Specific, testable criterion from the plan]
- [ ] [Another criterion — be concrete, not vague]
- [ ] Validation passes

## Implementation Notes
[Key files to modify, approach, relevant architecture docs — pull from plan discussion]
```

**Labels:** Apply project-specific labels as defined in CLAUDE.md. Common labels: `enhancement`, `bug`, `documentation`, `discovery`, `design`. Add `blocked` if issue has open dependencies.

### Naming and labeling guidelines

- Titles should be concise but descriptive — someone reading the backlog should understand the scope at a glance
- Use the plan's language when possible so issues are traceable back to the plan
- Label with ALL applicable labels (an issue touching multiple areas gets all relevant labels)

### Issue Type Extras

**Research/Discovery issues additionally include:**
- `## Findings` section placeholder
- `## Recommendation` section placeholder
- Criteria for what "done" looks like (e.g., "at least 3 candidates compared")

**Bug issues additionally include:**
- `## Reproduction` section with steps
- `## Errors` section with actual error output

## Step 4a. Specialist Review

While still in plan mode, spawn four specialist agents **in parallel** to review the drafted issues. Each agent receives the full draft batch and returns a structured verdict.

**1. Scope reviewer** (model: sonnet):
Review each issue for right-sizing. Is it a single implementation session? Is it secretly two issues bundled? Does the approach hide complexity that warrants a separate issue?
Return per issue: PASS | WARN | FAIL with a one-line recommendation for WARN/FAIL.

**2. Dependency reviewer** (model: haiku):
Review dependencies against existing open issues. Are all blockers identified and sequenced? Are there missing dependencies? Can work proceed in the stated order?
Return per dependency edge: PASS | WARN | FAIL with what's missing for WARN/FAIL.

**3. Acceptance criteria reviewer** (model: sonnet):
For each AC item: Is it specific and testable? Verifiable by code inspection or automated test? Free of vague language ("properly", "correctly", "as expected")?
Return per criterion: PASS | WARN | FAIL with a rewritten criterion for WARN/FAIL.

**4. Security reviewer** (model: haiku):
Scan for security-relevant gaps. Do issues touching auth, data handling, or external inputs have security-specific AC items? Are there missing security considerations?
Return: list of issues needing security AC additions.

**Integrate findings:** For each WARN/FAIL finding, update the drafted issues before presenting for review in Step 6. Rewrite vague AC items. Split over-scoped issues. Add missing dependencies. Add security AC items where flagged.

## Step 5. Validate Dependency Graph

Take ALL open issues + ALL proposed issues and validate:
- Build the combined dependency graph
- Run cycle detection — if adding the proposed issues creates a cycle, flag it and ask the user to resolve
- Verify that all referenced `#NN` blockers actually exist (open issues or within this batch)
- Verify the sequence matches what was discussed in the plan

## Step 6. Present for Review

Show the complete picture:

```
## Tracking Epic

**{epic title}**
[Full epic body preview]

## Implementation Issues (in dependency order)

| # | Title | Labels | Assignee | Blocked by | Blocks |
|---|-------|--------|----------|------------|--------|
| new-1 | feat(scope): ... | enhancement | @username | None | new-2 |
| new-2 | feat(scope): ... | enhancement | @username | new-1 | None |

### Issue Details

#### new-1: feat(scope): ...
[Full issue body preview]

#### new-2: feat(scope): ...
[Full issue body preview]

## Dependency Graph
new-1 -> new-2 -> new-3
              \-> new-4
```

Ask: "Create these N issues (1 epic + N-1 implementation issues)? You can ask to modify any before creating."

## Step 7. Create Issues

Create in dependency order (blockers first, then dependents). The tracking epic is created **first** so child issues can reference it.

For the epic, use the **create issue** operation (see `agent_docs/issue-tracker-ops.md`) with the `tracking` label and optional `$ASSIGNEE`.

For each child issue, use the **create issue** operation with appropriate labels and optional `$ASSIGNEE`.

After each creation:
- Note the real issue number assigned by the tracker
- Update subsequent issue bodies: replace batch IDs (`new-1`) with real issue references
- Update the epic's issue table with real `#NN` references
- Apply `blocked` label to issues whose dependencies are still open

After all child issues are created, **edit the epic** to fill in the real issue numbers using the **edit issue body** operation (see `agent_docs/issue-tracker-ops.md`).

## Step 8. Post-Creation Validation

After all issues are created:
- Fetch the updated issue list
- Rebuild the dependency graph
- Confirm no orphaned references or broken dependencies
- Show summary:
  ```
  Created N issues (1 epic + N-1 tasks):

  Epic: #90 — tracking: Add user authentication
  |-- #91: feat(scope): ... (ready) -> @username
  |-- #92: feat(scope): ... (ready) -> @username
  |-- #93: feat(scope): ... (blocked by #91, #92) -> @username
  \-- #94: docs: ... (blocked by #93) -> @username

  Assignee: @username
  ```

## Rules

- NEVER create issues without user confirmation
- NEVER create duplicate issues — if a similar issue exists, flag it and ask
- ALWAYS include `Validation passes` in acceptance criteria
- ALWAYS create a tracking epic when creating 2+ related issues
- ALWAYS include `Part of: #EPIC` in child issue dependencies
- Dependencies MUST use the canonical format: `- Blocked by: #NN — reason`
- One issue per discrete piece of work — don't combine unrelated changes
- If no plan exists in conversation, ask the user before inventing issues
- Preserve the sequence and rationale from the plan — issues should be traceable back to the discussion
