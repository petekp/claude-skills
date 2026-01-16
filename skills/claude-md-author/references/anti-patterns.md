# CLAUDE.md Anti-Patterns

Common mistakes that reduce CLAUDE.md effectiveness.

## Anti-Pattern 1: Using as a Linter

**Problem:** Including code style rules that should be enforced by tooling.

```markdown
## Code Style (DON'T DO THIS)
- Use 2 spaces for indentation
- Always use single quotes for strings
- Put opening braces on same line
- Maximum line length of 80 characters
- Always use trailing commas in arrays
- Prefer const over let
- Use arrow functions instead of function expressions
```

**Why it fails:**
- Wastes valuable instruction budget
- Claude may still produce inconsistent output
- Deterministic tools (ESLint, Prettier) do this better
- Every line here displaces something more valuable

**Better approach:**
```markdown
## Formatting
Code is auto-formatted on save via Prettier. Run `npm run format` to format all files.
```

Or use a Claude Code hook to run formatters automatically.

## Anti-Pattern 2: Auto-Generated Content

**Problem:** Running `/init` and accepting the verbose default output.

```markdown
## Project Overview (AUTO-GENERATED)
This project is a web application built using modern JavaScript technologies.
The application provides users with the ability to manage their tasks and
collaborate with team members in real-time. It features a responsive design
that works across desktop and mobile devices.

## Technology Stack
- **Frontend**: React.js - A JavaScript library for building user interfaces
- **Backend**: Node.js with Express - Fast, unopinionated web framework
- **Database**: PostgreSQL - Powerful, open source object-relational database
- **ORM**: Prisma - Next-generation Node.js and TypeScript ORM
[... continues for 200+ more lines ...]
```

**Why it fails:**
- Generic descriptions that apply to any project
- Explains well-known technologies Claude already understands
- Buries project-specific information in noise
- Uses instruction budget on obvious information

**Better approach:**
Manually craft content specific to your project's unique aspects.

## Anti-Pattern 3: Copying Code Blocks

**Problem:** Including actual code that will become stale.

```markdown
## Authentication Pattern (DON'T DO THIS)
\`\`\`typescript
export async function authenticateUser(req: Request): Promise<User> {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    throw new AuthError('No token provided');
  }
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  const user = await db.user.findUnique({ where: { id: decoded.userId } });
  if (!user) {
    throw new AuthError('User not found');
  }
  return user;
}
\`\`\`
```

**Why it fails:**
- Code drifts from reality as project evolves
- Takes many tokens to express what a pointer does better
- Claude may use outdated patterns from CLAUDE.md instead of actual code

**Better approach:**
```markdown
## Authentication
JWT-based auth with refresh tokens. See implementation: `src/auth/authenticate.ts:15`
```

## Anti-Pattern 4: Task-Specific Instructions

**Problem:** Including one-time or rarely-used procedures.

```markdown
## Migration from v1 to v2 (DON'T DO THIS)
When migrating from the old authentication system:
1. First, back up the users table
2. Run the migration script: `npm run migrate:auth`
3. Update all API clients to use new token format
4. Verify with test users before production rollout
[... continues with detailed migration steps ...]

## Setting Up Stripe Integration (DON'T DO THIS)
To configure Stripe for the first time:
1. Create a Stripe account
2. Get your API keys from the dashboard
[... detailed setup instructions ...]
```

**Why it fails:**
- Instructions only relevant for one session
- Wastes tokens in every session thereafter
- System reminder may flag CLAUDE.md as irrelevant

**Better approach:**
Store in separate files:
```markdown
## Setup Guides
- Auth migration: `.claude/docs/auth-migration.md`
- Stripe setup: `.claude/docs/stripe-setup.md`
```

## Anti-Pattern 5: Redundant Technology Explanations

**Problem:** Explaining technologies Claude already knows.

```markdown
## About Our Stack (DON'T DO THIS)
We use React for our frontend. React is a JavaScript library developed by
Facebook for building user interfaces. It uses a component-based architecture
and a virtual DOM for efficient updates.

PostgreSQL is our database. It's an advanced open-source relational database
that supports both SQL and JSON querying capabilities.

TypeScript extends JavaScript by adding static type definitions, helping
catch errors early in development and improving IDE support.
```

**Why it fails:**
- Claude already has extensive knowledge of common technologies
- Uses instruction budget on information Claude doesn't need
- No project-specific value

**Better approach:**
Only mention tech when there's project-specific context:
```markdown
## Stack Notes
- Using PostgreSQL's JSONB for flexible user preferences (not normalized)
- TypeScript strict mode enabled - no implicit any
```

## Anti-Pattern 6: Overwhelming Detail

**Problem:** Including every possible piece of information.

```markdown
## Complete File Structure (DON'T DO THIS)
src/
├── components/
│   ├── atoms/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.styles.ts
│   │   │   └── index.ts
│   │   ├── Input/
│   │   │   ├── Input.tsx
[... continues for 300+ lines ...]
```

**Why it fails:**
- Claude can explore the filesystem itself
- Static documentation becomes stale
- Creates analysis paralysis
- Better to let Claude discover structure as needed

**Better approach:**
```markdown
## Structure
- `src/components/` - React components (atomic design)
- `src/services/` - API integrations
- `src/hooks/` - Custom React hooks
```

## Anti-Pattern 7: Conditional/Branching Instructions

**Problem:** Instructions that only apply sometimes.

```markdown
## Deployment (DON'T DO THIS)
If deploying to staging:
1. Set NODE_ENV=staging
2. Use staging database credentials
3. Run npm run deploy:staging

If deploying to production:
1. Ensure all tests pass
2. Get approval from team lead
3. Set NODE_ENV=production
4. Run npm run deploy:prod
5. Monitor error rates for 30 minutes

If deploying a hotfix:
1. Create branch from production
2. Cherry-pick the fix
[... more conditional paths ...]
```

**Why it fails:**
- Most sessions don't involve deployment
- Conditional logic uses many instructions
- Claude may mix up different paths

**Better approach:**
```markdown
## Deployment
See deployment procedures: `.claude/docs/deployment.md`
```

## Summary: The Minimal Test

For every line in CLAUDE.md, ask:

1. Will this help in **every** session? → Keep only if yes
2. Is this something Claude already knows? → Remove
3. Can a tool enforce this better? → Use the tool
4. Could this be a separate document? → Move it
5. Does this duplicate file content? → Use a pointer

The best CLAUDE.md files feel surprisingly short. That's the point.
