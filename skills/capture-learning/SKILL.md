---
name: capture-learning
description: This skill should be used when the user asks to "capture this learning", "update the docs with this", "remember this for next time", "document this issue", "add this to CLAUDE.md", "save this knowledge", "update project knowledge", or when the user has just resolved an issue and wants to prevent it from happening again. Analyzes recent session context and updates project knowledge files.
---

# Capture Learning

Analyze recent conversation context and update project knowledge files with learnings to prevent recurring issues and document discoveries.

## When to Use

Invoke this skill when:
- A build, setup, or environment issue has been resolved
- A non-obvious pattern or convention has been discovered
- A debugging session revealed important insights
- The user explicitly asks to capture or document something
- Any knowledge worth preserving for future sessions emerges

## Core Workflow

### Step 1: Analyze Recent Context

Review the current conversation to identify:

1. **Problem encountered** - What went wrong or was confusing?
2. **Root cause** - Why did it happen?
3. **Solution** - How was it resolved?
4. **Prevention** - How to avoid this in the future?

Extract concrete, actionable insights—not vague summaries.

**Good learning:**
```
When running `npm install` on Node 20+, the `--legacy-peer-deps` flag
is required due to React 18 peer dependency conflicts.
```

**Bad learning:**
```
Had some issues with npm install, fixed it eventually.
```

### Step 2: Scan for Knowledge Files

Detect existing knowledge files in the project's `.claude/` directory:

```bash
# Primary targets (most common)
.claude/CLAUDE.md          # Main project instructions
./CLAUDE.md                # Root-level alternative

# Secondary targets
.claude/docs/*.md          # Reference documentation
.claude/docs/**/*.md       # Nested docs

# Tertiary (check but don't modify without explicit request)
.claude/plans/*.md         # Planning docs (usually ephemeral)
```

**Priority order for updates:**
1. `CLAUDE.md` (project root or `.claude/`) - General learnings, setup issues
2. `.claude/docs/troubleshooting.md` - If exists, for debugging insights
3. `.claude/docs/setup.md` - If exists, for environment/build issues
4. Create new file only if user requests it

### Step 3: Categorize the Learning

Determine which section the learning belongs in:

| Learning Type | Target Section | Example |
|--------------|----------------|---------|
| Build/dependency issues | `## Build & Setup` or `## Troubleshooting` | npm flags, version requirements |
| Environment setup | `## Environment` or `## Prerequisites` | env vars, tool versions |
| Code patterns | `## Patterns` or `## Conventions` | naming, architecture decisions |
| Known issues | `## Known Issues` or `## Gotchas` | quirks, workarounds |
| Debugging insights | `## Debugging` | how to diagnose specific problems |

If the target section doesn't exist, propose creating it in a logical location.

### Step 4: Draft the Update

Format the learning for documentation:

**Structure for issue-based learnings:**
```markdown
### [Short descriptive title]

**Problem:** [What went wrong]
**Cause:** [Why it happened]
**Solution:** [How to fix/prevent]
```

**Structure for pattern/convention learnings:**
```markdown
### [Pattern name]

[Brief description of when/why to use this pattern]

```code
[Example if applicable]
```
```

**Structure for quick tips:**
```markdown
- [Concise actionable tip]
```

Keep entries:
- **Scannable** - Use headers, bullets, code blocks
- **Actionable** - Provide concrete steps or commands
- **Contextual** - Explain *why*, not just *what*

### Step 5: Present Changes for Confirmation

Before modifying any file, show the user:

1. **Target file** - Which file will be updated
2. **Location** - Which section (existing or new)
3. **Proposed content** - Exact text to be added
4. **Diff preview** - Show context around insertion point

Example confirmation prompt:
```
I'll add this to `.claude/CLAUDE.md` under "## Troubleshooting":

### Node 20 Peer Dependency Fix

**Problem:** `npm install` fails with peer dependency conflicts
**Cause:** React 18 has strict peer deps incompatible with some packages
**Solution:** Run `npm install --legacy-peer-deps`

Should I apply this update?
```

Wait for explicit user approval before writing.

### Step 6: Apply the Update

After confirmation:

1. Read the target file
2. Find the appropriate insertion point
3. Add the new content with proper formatting
4. Write the updated file
5. Confirm the update was applied

If creating a new section, place it logically:
- Setup/build sections near the top
- Troubleshooting sections near the bottom
- Patterns/conventions in the middle

## File Detection Details

### Scanning Strategy

```bash
# Check for .claude directory
ls -la .claude/ 2>/dev/null

# Find all markdown files in .claude
find .claude -name "*.md" -type f 2>/dev/null

# Check root for CLAUDE.md
ls CLAUDE.md 2>/dev/null
```

### File Purpose Recognition

Infer file purpose from:
1. **Filename** - `troubleshooting.md`, `setup.md`, `patterns.md`
2. **Location** - `.claude/docs/` for references, `.claude/plans/` for planning
3. **Content** - Existing section headers indicate file's scope
4. **CLAUDE.md special handling** - Always a valid target for general learnings

### When No Suitable File Exists

If `.claude/CLAUDE.md` doesn't exist:

1. Check for `./CLAUDE.md` in project root
2. If neither exists, ask user:
   - Create `.claude/CLAUDE.md`?
   - Create a specific doc file (e.g., `.claude/docs/troubleshooting.md`)?
   - Skip capturing this time?

## Learning Extraction Patterns

### Build/Setup Issues

Look for conversation patterns:
- Error messages followed by resolution
- "Fixed by..." or "The solution was..."
- Version-specific workarounds
- Missing dependencies or configuration

Extract: The error, root cause, and fix command/steps.

### Code Patterns

Look for:
- "This codebase uses..." discoveries
- Architecture decisions explained
- Naming conventions identified
- Framework-specific patterns

Extract: Pattern description and rationale.

### Debugging Insights

Look for:
- Multi-step debugging processes
- Non-obvious root causes
- Diagnostic commands or techniques
- "The issue was actually..."

Extract: Symptoms, investigation steps, root cause.

## Examples

### Example 1: Build Issue

**Context:** Session involved fixing a failing build due to TypeScript version mismatch.

**Captured learning:**
```markdown
### TypeScript Version Requirement

**Problem:** Build fails with "Cannot find module 'typescript'"
**Cause:** Project requires TypeScript 5.3+ but system has 5.0
**Solution:**
```bash
npm install typescript@^5.3.0 --save-dev
```
```

### Example 2: Environment Setup

**Context:** Session discovered required environment variables.

**Captured learning:**
```markdown
### Required Environment Variables

The following must be set in `.env.local`:
- `DATABASE_URL` - PostgreSQL connection string
- `NEXTAUTH_SECRET` - Generate with `openssl rand -base64 32`
- `NEXTAUTH_URL` - Set to `http://localhost:3000` for development
```

### Example 3: Code Pattern

**Context:** Session uncovered project's error handling convention.

**Captured learning:**
```markdown
### Error Handling Pattern

All API routes use the `ApiError` class for consistent error responses:
```typescript
throw new ApiError(404, "Resource not found");
```
The error handler middleware converts these to JSON responses.
```

## Edge Cases

### Multiple Learnings

If the session contains multiple distinct learnings:
1. List them for the user
2. Ask which to capture (or all)
3. Process each separately with confirmation

### Conflicting Information

If new learning contradicts existing documentation:
1. Show both versions
2. Ask user which is correct
3. Update or replace as directed

### Sensitive Information

Never capture:
- API keys, tokens, or secrets
- Passwords or credentials
- Personal information
- Internal URLs that shouldn't be documented

If a learning involves secrets, document the *pattern* without the actual values.

## Quick Reference

**Trigger phrases:** "capture this", "remember this", "update docs", "document this", "add to CLAUDE.md", "save this knowledge"

**Target files:** `.claude/CLAUDE.md` (primary), `.claude/docs/*.md` (secondary)

**Always confirm:** Show exact changes before writing

**Format:** Problem → Cause → Solution (for issues), Description → Example (for patterns)

## Additional Resources

### Reference Files

- **`references/section-templates.md`** - Complete templates for common documentation sections (Troubleshooting, Build & Setup, Environment, Patterns, Known Issues, Debugging). Consult when creating new sections or structuring complex learnings.
