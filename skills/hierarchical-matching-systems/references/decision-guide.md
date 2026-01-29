# Algorithm Decision Guide

Use this flowchart to select the appropriate matching algorithm. Answer each question in order.

---

## Decision Flowchart

```
START
  │
  ▼
┌─────────────────────────────────────┐
│ Q1: Do BOTH sides have preferences? │
└─────────────────────────────────────┘
  │
  ├─► YES ──► Q2 (Two-Sided)
  │
  └─► NO ───► Q5 (One-Sided)


TWO-SIDED PATH
══════════════

┌────────────────────────────────────────┐
│ Q2: Is STABILITY required?             │
│ (No pair should prefer each other      │
│  over their assigned matches)          │
└────────────────────────────────────────┘
  │
  ├─► YES ──► Q3 (Stable Matching)
  │
  └─► NO ───► Q4 (Optimization)

┌────────────────────────────────────────┐
│ Q3: One-to-one or many-to-one?         │
└────────────────────────────────────────┘
  │
  ├─► ONE-TO-ONE ──► GALE-SHAPLEY
  │
  └─► MANY-TO-ONE ─► HOSPITAL-RESIDENT (Gale-Shapley variant)

┌────────────────────────────────────────┐
│ Q4: Do matches have weights/costs?     │
└────────────────────────────────────────┘
  │
  ├─► YES ──► Q6 (Weighted)
  │
  └─► NO ───► HOPCROFT-KARP (maximum cardinality)


ONE-SIDED PATH
══════════════

┌────────────────────────────────────────┐
│ Q5: Can ANY entity match ANY other?    │
│ (Non-bipartite graph)                  │
└────────────────────────────────────────┘
  │
  ├─► YES ──► BLOSSOM ALGORITHM
  │
  └─► NO ───► Q4 (Optimization)


WEIGHTED PATH
═════════════

┌────────────────────────────────────────┐
│ Q6: Is the preference graph sparse?    │
│ (Each entity prefers << n others)      │
└────────────────────────────────────────┘
  │
  ├─► YES (sparse) ──► AUCTION ALGORITHM
  │
  └─► NO (dense) ────► HUNGARIAN ALGORITHM


HIERARCHY PATH (applies to any above)
═════════════════════════════════════

┌────────────────────────────────────────┐
│ Q7: Is matching hierarchical/nested?   │
└────────────────────────────────────────┘
  │
  ├─► YES ──► Q8
  │
  └─► NO ───► Use algorithm from above directly

┌────────────────────────────────────────┐
│ Q8: Do parent decisions constrain      │
│     children, or do children inform    │
│     parent decisions?                  │
└────────────────────────────────────────┘
  │
  ├─► PARENT CONSTRAINS CHILDREN ──► TOP-DOWN + chosen algorithm per level
  │
  └─► CHILDREN INFORM PARENT ──────► BOTTOM-UP aggregation + match at root


ENTITY RESOLUTION PATH
══════════════════════

┌────────────────────────────────────────┐
│ Q9: Is this fuzzy/probabilistic        │
│     matching (entity resolution)?      │
└────────────────────────────────────────┘
  │
  ├─► YES ──► BLOCKING + SCORING pipeline
  │           (optionally Fellegi-Sunter for probabilistic)
  │
  └─► NO ───► Use decision tree above
```

---

## Quick Reference Table

| Requirement | Algorithm | Notes |
|-------------|-----------|-------|
| Two-sided, stable, 1:1 | Gale-Shapley | Proposer-optimal |
| Two-sided, stable, n:1 | Hospital-Resident | Capacity on one side |
| Weighted, optimal | Hungarian | O(n³), exact |
| Weighted, sparse | Auction | Better for sparse graphs |
| Max pairs, no weights | Hopcroft-Karp | Cardinality only |
| Non-bipartite | Blossom | General graphs |
| Fuzzy/probabilistic | Blocking + Scoring | Entity resolution |
| Hierarchical | Wrap any above | Add level traversal |

---

## Constraint Compatibility Matrix

Check that your constraints are compatible with the chosen algorithm:

| Constraint Type | Gale-Shapley | Hungarian | Hopcroft-Karp | Auction |
|-----------------|--------------|-----------|---------------|---------|
| Capacity (n:1) | ✓ (variant) | ✓ (expand) | ✓ (expand) | ✓ |
| Exclusions | ✓ (remove from list) | ✓ (∞ cost) | ✓ (remove edge) | ✓ |
| Required pairs | Partial¹ | ✓ (pre-assign) | ✓ (pre-assign) | ✓ |
| Coupling | Manual² | ✓ (composite) | Manual² | Manual² |
| Soft preferences | ✗ | ✓ (weights) | ✗ | ✓ |

¹ Can force by truncating preference lists, but may cause instability
² Requires creating composite entities or post-processing

---

## Decision Examples

### Example 1: School Choice

> Students rank schools, schools have capacities, want stable assignment

- Q1: Both sides have preferences? **YES**
- Q2: Stability required? **YES** (no student-school pair should want to deviate)
- Q3: One-to-one or many-to-one? **MANY-TO-ONE** (schools take multiple students)

**→ HOSPITAL-RESIDENT (student-proposing Gale-Shapley)**

### Example 2: Task Assignment

> Assign tasks to workers to minimize total cost, workers have capacity

- Q1: Both sides have preferences? **NO** (tasks don't prefer workers)
- Q5: Non-bipartite? **NO** (workers and tasks are distinct sets)
- Q4: Weighted? **YES** (minimizing cost)
- Q6: Sparse? **NO** (any worker can do any task)

**→ HUNGARIAN ALGORITHM** (expand workers to capacity)

### Example 3: Org Restructuring

> Match employees to new positions across department hierarchy

- Q7: Hierarchical? **YES** (org → dept → team → position)
- Q8: Direction? **PARENT CONSTRAINS** (dept capacity limits teams)
- Q1: Both sides have preferences? **YES** (employees rank positions, managers rank employees)
- Q2: Stability required? **YES**

**→ TOP-DOWN hierarchical Gale-Shapley**

### Example 4: Customer Deduplication

> Identify same customer across databases with fuzzy name/address matching

- Q9: Entity resolution? **YES**

**→ BLOCKING (by zip + name prefix) + SCORING (Jaro-Winkler on names) + threshold clustering**

---

## Red Flags: Wrong Algorithm Indicators

| Symptom | Likely Problem | Correct Choice |
|---------|----------------|----------------|
| "Optimal" but pairs defect | Used optimization when needed stability | Gale-Shapley family |
| Slow at scale (n > 5000) | Hungarian O(n³) too slow | Auction or Hopcroft-Karp |
| Matches feel "random" | Using max cardinality when need weights | Hungarian/Auction |
| Can't express preference strength | Using stable matching when need optimization | Hungarian/Auction |
| Blocking pairs exist | Wrong proposer side or incomplete lists | Check Gale-Shapley setup |

---

## Algorithm Selection Checklist

Before finalizing choice:

```
□ Algorithm handles all HARD constraints
□ Algorithm complexity acceptable for data size
□ Stability vs optimality tradeoff understood
□ Hierarchy traversal direction determined (if applicable)
□ Tie-breaking strategy compatible with algorithm
□ Edge cases documented (what happens with empty/single/tied?)
```
