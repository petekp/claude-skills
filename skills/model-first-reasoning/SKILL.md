---
name: model-first-reasoning
description: Apply Model-First Reasoning (MFR) to code generation tasks. Use when the user requests "model-first", "MFR", "formal modeling before coding", "model then implement", or when tasks involve complex logic, state machines, constraint systems, or any implementation requiring formal correctness guarantees. Enforces strict separation between modeling and implementation phases.
---

# Model-First Reasoning (MFR)

A rigorous code-generation methodology that REQUIRES constructing an explicit problem MODEL before any implementation. The model becomes a frozen contract that governs all code.

## Core Principle

**Phase 1 produces the MODEL. Phase 2 implements ONLY what the model specifies.**

This prevents the common failure mode where implementation introduces ad-hoc decisions, missing constraints, or invented behavior not grounded in requirements.

## Non-Negotiable Rules

1. **Phase 1 (Model)** produces NO code, no solution steps—only the formal model
2. **Phase 2 (Implement)** may NOT introduce new entities, state, actions, or constraints
3. If you need something not in the model: output exactly `MODEL INCOMPLETE` + what to add, then STOP
4. No invented APIs or dependencies. If not provided, either ask (unknowns) or create a stub clearly marked `STUB`

## The Model as Contract

After creating the model, run a **MODEL AUDIT** before coding:

### Audit Checks

| Check | Description |
|-------|-------------|
| **Coverage** | Every user requirement is represented in exactly one of: a constraint, the goal/acceptance criteria, or an action precondition/effect |
| **Operability** | Every operation your plan would require is present as an action |
| **Consistency** | Constraints don't contradict each other; action effects don't violate invariants |
| **Testability** | Every constraint has ≥1 test oracle |

If any audit check fails, revise the model (still Phase 1) until it passes.

## Freeze Rule

Once the audit passes, treat the model as **read-only source of truth**.

If later you discover missing info during implementation:
1. Emit a `MODEL PATCH` (minimal change)
2. Restart Phase 2 from scratch using the updated model

## Output Format

### Phase 1: MODEL

Return ONLY JSON with these keys:

```json
{
  "deliverable": {
    "description": "What we're building",
    "files_expected": ["path/to/file.ts", ...]
  },
  "entities": [
    {"name": "EntityName", "description": "...", "properties": [...]}
  ],
  "state_variables": [
    {"name": "varName", "type": "...", "initial": "...", "description": "..."}
  ],
  "actions": [
    {
      "name": "actionName",
      "description": "...",
      "preconditions": ["..."],
      "effects": ["..."],
      "parameters": [...]
    }
  ],
  "constraints": [
    {"id": "C1", "statement": "...", "type": "invariant|precondition|postcondition"}
  ],
  "initial_state": ["description of starting conditions"],
  "goal": ["acceptance criteria"],
  "assumptions": ["things we assume to be true"],
  "unknowns": ["questions that must be answered before proceeding"],
  "requirement_trace": [
    {
      "requirement": "<verbatim from user>",
      "represented_as": "goal|constraint|action",
      "ref": "C1|action_name|goal_item"
    }
  ],
  "test_oracles": [
    {"id": "T1", "maps_to": ["C1"], "description": "how to verify constraint"}
  ]
}
```

**Critical**: If `unknowns` is non-empty, STOP after Phase 1. Do not implement until unknowns are resolved.

### Phase 1.5: MODEL AUDIT

Return:

```json
{
  "audit_pass": true|false,
  "issues": [
    {"type": "coverage|operability|consistency|testability", "detail": "..."}
  ]
}
```

If `audit_pass` is false, STOP and return to Phase 1 to revise the model.

### Phase 2: IMPLEMENTATION

Using ONLY the frozen model:

#### A) PLAN

Numbered steps where each step must be an instance of a defined action:

```
Step 1: [action_name]
  - Preconditions check: [list which preconditions are satisfied]
  - Effects applied: [what state changes]
  - Constraints check: [C1, C2, ...]
```

#### B) CODE

Create all files in `deliverable.files_expected`:

| Model Element | Code Translation |
|---------------|------------------|
| entities / state_variables | Types, interfaces, data models |
| actions | Functions/modules with validation + explicit failure modes |
| constraints | Runtime checks, defensive parsing, invariants |

#### C) TESTS

Implement all `test_oracles`. Every constraint must be covered by ≥1 test.

#### D) VERIFICATION MAP

For each constraint, document:
- Where it is enforced in code (file:line)
- Which tests cover it

## When to Use MFR

MFR is most valuable for:

- **Complex state machines** - where transitions must be valid
- **Business logic with invariants** - rules that must never be violated
- **Data transformations** - where input/output contracts matter
- **Multi-step workflows** - with dependencies between steps
- **Safety-critical features** - where bugs have high cost
- **Collaborative specifications** - where the model serves as documentation

## Example Workflow

```
User: Build a shopping cart that enforces: max 10 items, no duplicate SKUs,
      total can't exceed $1000

You: [PHASE 1: MODEL]
{
  "entities": [
    {"name": "CartItem", "properties": ["sku", "price", "quantity"]}
  ],
  "constraints": [
    {"id": "C1", "statement": "cart.items.length <= 10", "type": "invariant"},
    {"id": "C2", "statement": "all SKUs in cart are unique", "type": "invariant"},
    {"id": "C3", "statement": "sum(items.price * items.quantity) <= 1000", "type": "invariant"}
  ],
  "actions": [
    {
      "name": "addItem",
      "preconditions": ["cart.items.length < 10", "sku not in cart", "new total <= 1000"],
      "effects": ["item added to cart"]
    }
  ],
  ...
}

[PHASE 1.5: MODEL AUDIT]
{
  "audit_pass": true,
  "issues": []
}

[PHASE 2: IMPLEMENTATION]
// Now implementing strictly from the model...
```

## Remember

The model is not overhead—it IS the specification. Code without a model is code without a contract. When implementation diverges from requirements, it's usually because the requirements were never made explicit.

**Model first. Then code. Never invert this.**
