---
name: grillme
description: Relentlessly interview the user about a feature or initiative until every branch of the decision tree is resolved, then produce a structured plan ready for /create-issues
user_invocable: true
---

# /grillme — Comprehensive Planning Interview

Transform a vague idea into a structured, unambiguous plan by working through every decision branch before a single line of code is written.

## Philosophy

Never start building until the decision tree is fully resolved. This command conducts a structured interview — exploring the codebase to answer questions where possible, and pressing for clarity everywhere else. The output feeds directly into `/create-issues`.

## Invocation

```
/plan                              # Start from scratch — ask what we're building
/plan "Add user authentication"    # Start with a stated goal
```

## Phase 1. Orient

If a goal was provided, restate it back to confirm understanding.

If no goal was provided, ask: "What are we building? Describe the feature, bug fix, or initiative in as much detail as you have."

Then immediately explore the codebase for relevant context:
- What existing modules, services, or patterns are relevant to this goal?
- What shared types, interfaces, or contracts exist in this area?
- What tests already exist in the affected area?
- Is there any existing work (branches, open issues) related to this goal?

Present a brief summary: "Before I start asking questions, here's what I found in the codebase: [summary]. This informed some of my questions below."

## Phase 2. Interrogate

Conduct a relentless interview across five dimensions. For each question:
- **Provide your recommended answer** based on codebase exploration and best practices
- Ask the user to confirm, override, or elaborate
- If a question can be fully answered by reading the codebase, answer it yourself without asking

Work through each dimension completely before moving to the next. Resolve dependencies between decisions as you go — if the answer to one question changes what you'd ask next, adapt.

### Dimension 1: Goals & Success Criteria
- What does "done" look like? What can a user do after this that they couldn't before?
- How will we know this works? What are the observable behaviors?
- Are there explicit non-goals — things out of scope?
- What's the priority driver: correctness, speed, simplicity, or extensibility?

### Dimension 2: Users & Inputs
- Who or what triggers this? (user action, background job, external event, another service?)
- What are the inputs? What validation is required?
- What are the boundary cases — empty, oversized, malformed, concurrent?

### Dimension 3: Architecture & Integration
- Where does this fit in the current architecture? (new module, extend existing, cross-cutting?)
- What existing components does this touch or depend on?
- What new dependencies (packages, services, infrastructure) does this require?
- Is there an existing pattern in the codebase we should follow? (explore codebase to answer this)
- Does this change any shared contracts — APIs, types, database schemas, events?

### Dimension 4: Failure Modes & Edge Cases
- What happens when this fails? How does the user/system know?
- What are the rollback or recovery paths?
- Are there race conditions, concurrency issues, or ordering constraints?
- What security considerations apply? (auth, data exposure, input injection)

### Dimension 5: Implementation Sequencing
- What's the smallest slice that delivers value? Can this be phased?
- What must be built first? What can be parallelized?
- Are there existing issues or in-progress work that block or overlap this?
- What's the testing strategy? (unit, integration, e2e — what level fits best?)

## Phase 3. Synthesize

Once all five dimensions are resolved, produce a structured plan:

```markdown
## Plan: {goal title}

### Context
{1-2 sentences on why we're doing this, informed by the interview}

### Scope
**In scope:**
- {explicit inclusion}

**Out of scope:**
- {explicit exclusion}

### Architecture
{How this fits the existing system — reference specific modules/files found during exploration}

### Implementation Sequence
1. {Step 1 — what, why first, acceptance signal}
2. {Step 2 — what, depends on step 1, acceptance signal}
3. {Step 3 — ...}

### Key Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| {decision} | {answer confirmed in interview} | {why} |

### Risks & Mitigations
| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| {risk} | High/Med/Low | {mitigation} |

### Testing Strategy
{How we'll verify this — test levels, key scenarios to cover}
```

Present the plan and ask: "Does this capture everything? Any changes before I hand this to `/create-issues`?"

## Phase 4. Hand Off

Once the plan is approved, offer to continue: "Ready to break this into issues? Run `/create-issues` and I'll use this plan as input."

## Rules

- NEVER skip a dimension — incomplete plans cause rework
- ALWAYS provide a recommended answer before asking — don't leave the user guessing
- ALWAYS explore the codebase before asking questions the code can answer
- NEVER produce the plan until all five dimensions are resolved
- If the user says "just figure it out" or wants to skip questions, complete the interview yourself using codebase exploration and sensible defaults, then present the plan for one final review pass
- The plan output MUST be specific enough for `/create-issues` to generate acceptance criteria without guessing
