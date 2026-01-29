# Algorithm Reference

Concise summaries of core matching algorithms. Use with [decision-guide.md](decision-guide.md) for selection.

---

## Two-Sided Stable Matching

### Gale-Shapley (Deferred Acceptance)

**Problem**: Match two groups where both sides have preferences. Find stable matching (no blocking pairs).

**Complexity**: O(n²) time, O(n) space

**Mechanism**:
```
while unmatched proposers exist:
    proposer proposes to highest-ranked unproposed receiver
    receiver tentatively accepts if:
        - unmatched, OR
        - prefers proposer over current match
    rejected proposers continue to next choice
```

**Properties**:
- Proposer-optimal: proposers get best stable partner
- Receiver-pessimal: receivers get worst stable partner
- Strategy-proof for proposers (not receivers)

**Variants**:
| Variant | Use Case |
|---------|----------|
| Hospital-Resident | Many-to-one (capacity > 1 on one side) |
| College Admissions | Hospital-Resident with quotas |
| Stable Roommates | One-sided (everyone can match anyone) |

**Pitfalls**:
- Tie-breaking affects outcome—document method
- Incomplete preferences need explicit handling
- Proposer/receiver role assignment matters

---

## Assignment/Optimization

### Hungarian Algorithm (Kuhn-Munkres)

**Problem**: Bipartite weighted matching. Minimize total cost (or maximize total value).

**Complexity**: O(n³) time, O(n²) space

**Mechanism**:
```
1. Subtract row minima, then column minima
2. Cover all zeros with minimum lines
3. If lines < n: adjust matrix, repeat
4. If lines = n: find perfect matching through zeros
```

**Properties**:
- Finds globally optimal assignment
- Works with any real-valued weights
- Handles maximization by negating weights

**Pitfalls**:
- Requires complete bipartite graph (add dummy nodes if needed)
- Equal-sized partitions (pad smaller side)
- O(n³) may be slow for n > 10,000

### Auction Algorithm

**Problem**: Same as Hungarian, but better for sparse graphs.

**Complexity**: O(nm log(nC)) where C = max weight, m = edges

**When to prefer over Hungarian**:
- Sparse preference graphs
- Parallel/distributed implementation needed
- Approximate solution acceptable (with early stopping)

---

## Maximum Matching (Unweighted)

### Hopcroft-Karp

**Problem**: Maximum cardinality bipartite matching (most pairs, no weights).

**Complexity**: O(E√V) time

**Use when**: Only care about match count, not quality/cost.

### Blossom Algorithm (Edmonds)

**Problem**: Maximum matching in general (non-bipartite) graphs.

**Complexity**: O(V²E) time

**Use when**: Entities can match any other entity (not strictly two-sided).

---

## Multi-Level / Hierarchical

### Top-Down Propagation

**Mechanism**:
```
for each level from root to leaf:
    match at current level
    propagate constraints to children
    children inherit parent assignments
```

**Use when**: Parent decisions constrain children.

### Bottom-Up Aggregation

**Mechanism**:
```
for each level from leaf to root:
    compute preferences at current level
    aggregate to parent level
    match at root, then assign downward
```

**Use when**: Leaf-level preferences determine parent matching.

### Hierarchical Stable Matching

**Extension of Gale-Shapley for nested structures**:
- Match at each level respecting parent constraints
- Children can only match within parent's match scope
- Requires clear inheritance rules

---

## Entity Resolution

### Blocking + Scoring Pipeline

**Mechanism**:
```
1. BLOCKING: Reduce comparison space
   - Group by key attributes (name prefix, zip code)
   - Compare only within blocks

2. SCORING: Compute similarity
   - String similarity (Jaro-Winkler, Levenshtein)
   - Attribute-weighted combination

3. CLUSTERING: Group matches
   - Threshold-based pairing
   - Transitive closure for groups
```

**Complexity**: O(b × n²/b) = O(n²/b) where b = block count

### Fellegi-Sunter Model

**Probabilistic record linkage**:
- Model match vs non-match probability per attribute
- Compute likelihood ratio
- Classify: match / non-match / review

**Use when**: Training data available for probability estimation.

---

## Complexity Comparison

| Algorithm | Time | Space | Best For |
|-----------|------|-------|----------|
| Gale-Shapley | O(n²) | O(n) | Two-sided stability |
| Hungarian | O(n³) | O(n²) | Optimal weighted assignment |
| Auction | O(nm log nC) | O(n+m) | Sparse weighted |
| Hopcroft-Karp | O(E√V) | O(V+E) | Max cardinality |
| Blossom | O(V²E) | O(V+E) | Non-bipartite |

---

## Implementation Checklist

For any algorithm implementation:

```
□ Tie-breaking documented and deterministic
□ Incomplete preferences handled (reject/default/exclude)
□ Input validation before algorithm runs
□ Intermediate state inspectable for debugging
□ Output includes match metadata (scores, iterations, unmatched)
□ Edge cases tested (empty, single, all-tied)
```
