# CLAUDE.md Examples

Real-world examples demonstrating effective CLAUDE.md patterns.

## Minimal Example (~40 lines)

A lean, effective CLAUDE.md for a typical web application:

```markdown
# TaskFlow API

REST API for task management built with Express and PostgreSQL.

## Commands
- Start dev: `npm run dev`
- Test: `npm test`
- Lint: `npm run lint`
- Build: `npm run build`
- Migrate DB: `npm run db:migrate`

## Stack
- Express 4.x with TypeScript
- PostgreSQL 15 with Prisma ORM
- Jest for testing
- Zod for validation

## Structure
- `src/routes/` - API route handlers
- `src/services/` - Business logic
- `src/models/` - Prisma schema and types
- `src/middleware/` - Auth, validation, error handling

## Patterns
- All routes use async error wrapper: `src/middleware/asyncHandler.ts:12`
- Service layer returns Result types: `src/types/result.ts:5`
- Validation schemas co-located with routes

## Notes
- Auth uses JWT with refresh tokens (not sessions)
- All times stored as UTC in database
- Soft deletes via `deletedAt` column
```

## Monorepo Example

Structure-focused CLAUDE.md for complex monorepos:

```markdown
# Acme Platform

Monorepo containing frontend, backend, and shared packages.

## Commands
- Install all: `pnpm install`
- Build all: `pnpm build`
- Test all: `pnpm test`
- Dev frontend: `pnpm --filter @acme/web dev`
- Dev backend: `pnpm --filter @acme/api dev`

## Structure
packages/
├── web/          # Next.js frontend
├── api/          # Express backend
├── ui/           # Shared React components
├── config/       # Shared ESLint, TS configs
└── types/        # Shared TypeScript types

## Package Dependencies
- `@acme/web` depends on `@acme/ui`, `@acme/types`
- `@acme/api` depends on `@acme/types`
- Changes to `@acme/types` require rebuilding dependents

## Working in Packages
Always run commands from package directory or use filters:
- `cd packages/web && npm test`
- `pnpm --filter @acme/web test`

## Notes
- Turborepo handles build caching
- Shared types ensure API contract consistency
```

## Library/SDK Example

Documentation-focused for published packages:

```markdown
# CloudSync SDK

TypeScript SDK for CloudSync API integration.

## Commands
- Build: `npm run build`
- Test: `npm test`
- Test watch: `npm run test:watch`
- Docs: `npm run docs`
- Publish: `npm run release`

## Stack
- TypeScript with strict mode
- Vitest for testing
- TypeDoc for documentation
- Semantic release for versioning

## Structure
- `src/client/` - Main SDK client class
- `src/resources/` - API resource classes (users, files, etc.)
- `src/types/` - Public type definitions
- `src/internal/` - Private utilities (not exported)

## Patterns
- All public APIs documented with TSDoc
- Resources follow builder pattern: `src/resources/files.ts:24`
- Errors extend `CloudSyncError`: `src/errors.ts:8`

## Publishing
- Conventional commits required
- CI handles npm publish on main
- Breaking changes bump major version
```

## CLI Tool Example

Command-focused for CLI applications:

```markdown
# DevOps CLI

Command-line tool for managing cloud infrastructure.

## Commands
- Build: `cargo build --release`
- Test: `cargo test`
- Install locally: `cargo install --path .`
- Run: `./target/release/devops`

## Stack
- Rust with clap for argument parsing
- tokio for async operations
- serde for config serialization

## Structure
- `src/commands/` - Subcommand implementations
- `src/config/` - Config file handling
- `src/providers/` - Cloud provider integrations

## Adding Commands
1. Create handler in `src/commands/`
2. Register in `src/commands/mod.rs`
3. Add clap subcommand in `src/main.rs:45`

## Config
- Global config: `~/.config/devops/config.toml`
- Project config: `.devops.toml` in project root
- Project overrides global settings
```

## Python Data Science Example

Environment-focused for Python projects:

```markdown
# Market Analyzer

Python package for financial market analysis.

## Commands
- Install: `pip install -e ".[dev]"`
- Test: `pytest`
- Type check: `mypy src/`
- Format: `black src/ tests/`
- Notebook: `jupyter lab`

## Stack
- Python 3.11+
- pandas, numpy for data manipulation
- scikit-learn for ML models
- pytest for testing

## Structure
- `src/market_analyzer/` - Main package
- `notebooks/` - Jupyter notebooks for exploration
- `data/` - Sample datasets (gitignored in prod)

## Virtual Environment
Always activate before working:
```bash
source .venv/bin/activate
```

## Notes
- Heavy computation uses multiprocessing
- Models cached in `~/.cache/market_analyzer/`
- API keys stored in `.env` (never committed)
```

## Key Observations

These examples share common traits:

1. **Under 60 lines** - Most fit in a single screen
2. **Commands first** - The most frequently needed info
3. **Structure overview** - Just the key directories
4. **Pointers not copies** - Reference files, not inline code
5. **Project-specific notes** - Non-obvious behaviors only
