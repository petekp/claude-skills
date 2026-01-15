---
description: Create a package for another LLM to review your current work
argument-hint: [optional focus area]
---

# Review Package Creator

Create a comprehensive package of your current work that can be handed off to another LLM for review. The package includes a README with context and all relevant files.

## Phase 1: Gather Requirements

Ask the user two questions using AskUserQuestion:

**Question 1: Review Type**
- Header: "Review type"
- Question: "What type of review do you need?"
- Options:
  1. **Code review** — Line-by-line feedback on implementation, bugs, edge cases, best practices
  2. **Architecture review** — High-level feedback on patterns, structure, design decisions
  3. **Both** — Comprehensive review covering code and architecture

**Question 2: Specific Concerns**
- Header: "Focus areas"
- Question: "Any specific concerns you want the reviewer to address?"
- multiSelect: true
- Options:
  1. **General review** — No specific focus, broad feedback welcome
  2. **Performance** — Efficiency, optimization opportunities
  3. **Security** — Vulnerabilities, input validation, auth patterns
  4. **Maintainability** — Code clarity, complexity, future extensibility

Wait for user responses before proceeding.

## Phase 2: Deep Analysis

Spawn the review-package-analyzer agent to analyze the codebase.

Use the Task tool with:
- **subagent_type**: `review-package-analyzer`
- **prompt**: Include the following context:
  ```
  Analyze this codebase for a review package.

  Focus area: [use $ARGUMENTS if provided, otherwise "current work based on git status and recent changes"]
  Review type: [user's selection from Phase 1]
  Project root: [current working directory]

  Return your analysis in the specified format.
  ```

Wait for the agent to complete and return its analysis.

## Phase 3: Generate README

Using the analysis results and user's concerns, write a README.md file.

Create a temp file at `/tmp/review-readme-$$.md` with this structure:

```markdown
# Review Package

**Generated**: [current date/time]
**Review Type**: [Code Review / Architecture Review / Both]
**Focus**: [focus area or "Current work"]

---

## What's Being Reviewed

[Use WORK_SUMMARY from analysis - expand slightly to give reviewer clear context]

## Reviewer Focus Areas

[Based on user's selected concerns from Phase 1]

- [ ] [Specific thing to check based on concern 1]
- [ ] [Specific thing to check based on concern 2]
- [ ] [Any custom concerns user mentioned]

## Project Context

[Use PROJECT_CONTEXT from analysis]

**Tech Stack**: [extracted from analysis]
**Key Patterns**: [any patterns noted]

## Files Included

### Core Files (Primary Review Targets)

| File | Purpose |
|------|---------|
| `path/to/file.ts` | [description from analysis] |

### Supporting Context

| File | Relevance |
|------|-----------|
| `path/to/util.ts` | [why included] |

### Tests

| File | Coverage |
|------|----------|
| `path/to/test.ts` | [what's tested] |

## Architecture Notes

[Use ARCHITECTURE_NOTES from analysis - important for architecture reviews]

## Known Areas of Concern

[Use POTENTIAL_CONCERNS from analysis]

---

## How to Review

[Tailor based on review type]

**For Code Review:**
1. Start with core files - these are the primary review targets
2. Reference supporting context as needed
3. Check tests for coverage gaps
4. Flag: bugs, edge cases, error handling, performance issues, unclear code

**For Architecture Review:**
1. Understand the project context and patterns first
2. Evaluate structure and separation of concerns
3. Consider scalability and maintainability
4. Flag: coupling issues, abstraction problems, missing patterns, tech debt

**Response Format Suggestion:**
Structure your review with:
- **Critical**: Must fix before shipping
- **Important**: Should address soon
- **Suggestions**: Nice to have improvements
- **Questions**: Clarifications needed
```

## Phase 4: Create File List

Extract all file paths from the analysis (Core, Related, Tests, Config sections).

Write them to a temp file at `/tmp/review-filelist-$$.txt`, one path per line:
```
path/to/core/file1.ts
path/to/core/file2.ts
path/to/related/util.ts
path/to/tests/file1.test.ts
```

## Phase 5: Create Package

Run the packaging script:

```bash
~/.claude/scripts/create-review-zip.sh \
  "$(pwd)" \
  "/tmp/review-readme-$$.md" \
  "/tmp/review-filelist-$$.txt" \
  "review-package-$(date +%Y%m%d-%H%M%S)"
```

Clean up temp files after the script completes:
```bash
rm -f /tmp/review-readme-$$.md /tmp/review-filelist-$$.txt
```

## Phase 6: Report Success

Tell the user:

```
✓ Review package created!

📦 Location: /tmp/review-package-YYYYMMDD-HHMMSS.zip
📋 Copied to clipboard - paste into Finder or upload dialog

Package contains:
- README.md with context for the reviewer
- [N] files ([X] core, [Y] related, [Z] tests)

Next: Paste the zip into ChatGPT, Claude, or your preferred LLM and ask it to review.
```

## Notes

- If $ARGUMENTS is empty, the analyzer will auto-detect current work from git status and recent file changes
- The package is self-contained - the reviewing LLM needs no other context
- Files are copied with directory structure preserved
- Binary files and build artifacts are excluded automatically
