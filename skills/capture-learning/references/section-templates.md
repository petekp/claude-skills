# Section Templates for Knowledge Files

Reference templates for common documentation sections. Use these when creating new sections or structuring learnings.

## CLAUDE.md Section Templates

### Troubleshooting Section

```markdown
## Troubleshooting

### [Issue Title]

**Symptoms:** [What you observe]
**Cause:** [Root cause]
**Solution:**
```bash
[fix command]
```

### [Another Issue]
...
```

### Build & Setup Section

```markdown
## Build & Setup

### Prerequisites

- Node.js 18+ (`node --version`)
- pnpm 8+ (`pnpm --version`)

### First-Time Setup

```bash
pnpm install
cp .env.example .env.local
# Edit .env.local with your values
pnpm dev
```

### Common Build Issues

[Issue entries here]
```

### Environment Section

```markdown
## Environment

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | Database connection | `postgresql://...` |
| `API_KEY` | External API key | Get from dashboard |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Logging verbosity | `info` |
```

### Patterns & Conventions Section

```markdown
## Patterns & Conventions

### [Pattern Name]

**When to use:** [Situation]
**How to implement:**
```typescript
[code example]
```
**Why:** [Rationale]

### Naming Conventions

- Components: PascalCase (`UserProfile.tsx`)
- Hooks: camelCase with `use` prefix (`useAuth.ts`)
- Utils: camelCase (`formatDate.ts`)
```

### Known Issues Section

```markdown
## Known Issues

### [Issue Title]

**Status:** [Open/Workaround available/Won't fix]
**Description:** [What happens]
**Workaround:**
```bash
[workaround steps]
```
**Tracking:** [Link to issue if applicable]
```

### Debugging Section

```markdown
## Debugging

### [Problem Category]

**Symptoms:** [What you see]
**Diagnostic steps:**
1. Check [thing]
2. Run `[command]`
3. Look for [pattern]

**Common causes:**
- [Cause 1]: [Fix]
- [Cause 2]: [Fix]
```

## Standalone Doc Templates

### troubleshooting.md

```markdown
# Troubleshooting Guide

Common issues and their solutions.

## Build Issues

### [Issue]
...

## Runtime Issues

### [Issue]
...

## Environment Issues

### [Issue]
...
```

### setup.md

```markdown
# Setup Guide

## Prerequisites

[List requirements]

## Installation

[Step-by-step]

## Configuration

[Environment variables, config files]

## Verification

[How to test setup worked]

## Common Setup Issues

[Issues specific to setup]
```

### patterns.md

```markdown
# Code Patterns

Documented patterns and conventions for this codebase.

## Architecture

[High-level patterns]

## Component Patterns

[UI/component patterns]

## Data Patterns

[Data fetching, state management]

## Error Handling

[Error handling patterns]
```

## Inline Learning Formats

### Quick Tip (single line)

```markdown
- Run `pnpm typecheck` before committing to catch type errors early.
```

### Short Note (2-3 lines)

```markdown
**Note:** The `dev` script uses Turbopack. For webpack behavior, use `dev:webpack`.
```

### Detailed Entry (structured)

```markdown
### [Title]

**Problem:** [Description]
**Cause:** [Why it happens]
**Solution:** [How to fix]
**Prevention:** [How to avoid in future]
```

## Placement Guidelines

| Learning Type | Preferred Section | File Priority |
|--------------|-------------------|---------------|
| Build failure fix | Troubleshooting | CLAUDE.md |
| Environment var | Environment | CLAUDE.md > setup.md |
| Code convention | Patterns | CLAUDE.md > patterns.md |
| Workaround | Known Issues | CLAUDE.md |
| Debug technique | Debugging | CLAUDE.md > troubleshooting.md |
| Setup step | Build & Setup | CLAUDE.md > setup.md |
