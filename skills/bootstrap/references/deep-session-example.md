# Deep Session Bootstrap Example

This example shows a comprehensive bootstrap prompt for a complex, multi-session project.

---

# Bootstrap: Authentication System Refactor

> Generated: 2025-01-15 16:45
> Project: /Users/dev/acme-platform
> Branch: refactor/auth-v2

## Context

Refactoring the authentication system from session-based auth to JWT with refresh tokens. This is part of a larger initiative to support mobile clients and third-party API access. The existing auth system is tightly coupled throughout the codebase.

## Session Summary

**Session 3 of ongoing refactor.** Previous sessions established the JWT strategy and created the core token service. This session focused on:

1. Implemented refresh token rotation with jti tracking
2. Created migration path for existing sessions
3. Discovered and documented edge cases around token revocation
4. Started work on the auth middleware refactor (incomplete)

Key insight: The original plan to use Redis for token blacklisting won't work because our Redis cluster doesn't guarantee consistency across regions. Switched to database-backed revocation with an in-memory cache (5-minute TTL acceptable for our security model).

## Current State

**Working:**
- `src/services/TokenService.ts` - JWT generation, validation, refresh rotation
- `src/services/TokenRevocationService.ts` - Database-backed revocation with cache
- `src/migrations/20250115_add_refresh_tokens.sql` - Schema changes (tested locally)
- Unit tests passing for token services

**In Progress:**
- `src/middleware/auth.ts` - Partially refactored, currently broken
  - Old session validation removed
  - JWT validation added but not handling refresh flow
  - Need to add: token refresh on near-expiry, proper error responses

**Not Started:**
- Update all protected routes to use new middleware
- Client-side token management (separate PR)
- Documentation updates

## Git State

**Branch:** `refactor/auth-v2`
**Status:** 12 commits ahead of main

### Recent Commits

```
a1b2c3d Add token revocation service with cache layer
e4f5g6h Implement refresh token rotation
i7j8k9l Add refresh_tokens table migration
m0n1o2p Create TokenService with JWT generation
q3r4s5t Initial auth refactor scaffold
```

### Uncommitted Changes

**Modified:**
- `src/middleware/auth.ts` (in progress, broken state)
- `src/middleware/auth.test.ts` (tests for new behavior)

## Key Files

| File | Purpose |
|------|---------|
| `src/services/TokenService.ts` | Core JWT operations, refresh rotation |
| `src/services/TokenRevocationService.ts` | Handles logout and forced revocation |
| `src/middleware/auth.ts` | **IN PROGRESS** - Request authentication |
| `src/types/auth.ts` | Type definitions for tokens and claims |
| `src/config/auth.ts` | Token expiry times, secret references |

## Decisions Made

**JWT Library:** Using `jose` over `jsonwebtoken`
- Rationale: Better TypeScript support, actively maintained, supports all algorithms we need

**Refresh Token Storage:** Database with jti in token
- Rationale: Need to support revocation, can't use stateless approach
- Trade-off: Slight latency increase, acceptable for security model

**Token Revocation:** Database + in-memory cache (5min TTL)
- Rationale: Redis cluster doesn't guarantee cross-region consistency
- Trade-off: Up to 5 minute window for revoked tokens, acceptable per security team

**Access Token Expiry:** 15 minutes
**Refresh Token Expiry:** 7 days (rotated on use)

## Gotchas & Warnings

1. **Don't use `jsonwebtoken` library** - Has issues with async/await and TypeScript types. We standardized on `jose`.

2. **Token refresh race condition** - When access token expires, multiple concurrent requests may try to refresh. The `TokenService.refresh()` method handles this with jti locking, but the middleware needs to queue/retry failed refreshes rather than immediately 401.

3. **Migration order matters** - The `refresh_tokens` migration must run before deploying new code. Old code ignores the table, but new code requires it.

4. **Test user tokens** - The test fixtures use hardcoded tokens that will break with the new system. There's a `scripts/generate-test-tokens.ts` that needs to run after the token service is available.

5. **Redis cache vs database** - The revocation cache is LOCAL to each instance. If you're testing revocation, you need to wait for cache TTL or test against the same instance.

## Next Steps

1. **Complete auth middleware** (`src/middleware/auth.ts`)
   - Add automatic token refresh when access token near expiry (<2min)
   - Handle refresh failures gracefully (clear tokens, redirect to login)
   - Add proper error responses (401 vs 403 distinction)
   - Tests are stubbed in `auth.test.ts`

2. **Update route handlers**
   - Find all uses of `req.session.user` and update to `req.user` (from JWT claims)
   - Search pattern: `rg "req\.session\.user" src/`

3. **Integration testing**
   - Test full flow: login → access → refresh → logout → verify revoked
   - Test concurrent refresh handling

4. **PR for token services** (could split from middleware work)
   - TokenService and TokenRevocationService are ready for review

## Resume Instructions

```bash
# Get to the right state
cd /Users/dev/acme-platform
git checkout refactor/auth-v2

# See what's uncommitted
git status
git diff src/middleware/auth.ts

# Run tests to see current state
npm test -- --grep "auth"

# The middleware file is the active work
code src/middleware/auth.ts src/middleware/auth.test.ts
```

Start by reviewing the current state of `auth.ts` - it's partially refactored and the tests show what behavior is expected. The `TokenService` is complete and can be used as reference for the refresh flow.

---

## Notes on This Example

This bootstrap prompt is comprehensive because:
- Multi-session project with accumulated decisions
- Complex domain with non-obvious gotchas
- Partial work in progress that needs careful handoff
- Architectural decisions that shouldn't be re-litigated

For simpler sessions, most of these sections would be omitted or condensed.
