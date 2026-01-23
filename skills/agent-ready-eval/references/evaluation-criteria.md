# Agent-Ready Evaluation Criteria

## Scoring Guide

Each principle is scored 0-3:
- **3 (Excellent)**: Fully implements the principle with clear evidence
- **2 (Good)**: Partially implements with room for improvement
- **1 (Minimal)**: Some awareness but significant gaps
- **0 (Missing)**: No evidence of implementation

---

## 1. Sandbox Everything

**What to look for:**
- Container/Docker configuration (Dockerfile, docker-compose.yml, .devcontainer/)
- Environment isolation scripts
- Ephemeral environment setup (teardown scripts, cleanup routines)
- CI/CD pipelines that spin up fresh environments
- Nix/devbox/similar reproducible environment tools

**Evidence of good implementation:**
- Each run creates isolated environment
- Explicit network scoping (firewall rules, network policies)
- Environment destruction after runs
- No shared mutable state between runs

**Red flags:**
- Direct execution on host machine assumed
- No containerization strategy
- Persistent environments reused across runs

---

## 2. No External Database Dependencies

**What to look for:**
- Database setup scripts that create local instances
- In-memory database options (SQLite, H2, embedded Postgres)
- Docker-based database services
- Migration scripts run as part of setup
- Explicit seed data files
- Database teardown in cleanup

**Evidence of good implementation:**
- `docker-compose.yml` with database services
- Scripts like `setup-db.sh`, `seed.sh`, `teardown.sh`
- Test fixtures with explicit data
- No hardcoded connection strings to external hosts

**Red flags:**
- Connection strings pointing to staging/production
- Shared database credentials in config
- No local database option
- Tests dependent on external data state

---

## 3. Clean Environment (No Environment Garbage)

**What to look for:**
- Lockfiles (package-lock.json, yarn.lock, Pipfile.lock, Cargo.lock)
- Explicit dependency declarations
- No implicit global dependencies
- Fresh install scripts
- CI that starts from clean state
- `.gitignore` properly configured

**Evidence of good implementation:**
- Reproducible builds from scratch
- All dependencies declared explicitly
- No "works on my machine" assumptions
- Setup docs assume clean environment

**Red flags:**
- Instructions like "assuming you have X installed"
- Global package dependencies
- Undocumented system requirements
- Build artifacts committed to repo

---

## 4. Session-Independent Execution

**What to look for:**
- Background job infrastructure (queues, workers)
- Webhook/callback patterns for completion notification
- Persistent task state storage
- Timeout and resource limit configuration
- Graceful shutdown handling
- Task resumption capabilities

**Evidence of good implementation:**
- Tasks can complete without active client
- Progress persisted to durable storage
- Explicit timeouts and limits configured
- Results retrievable after completion

**Red flags:**
- Execution tied to HTTP request lifecycle
- No background processing capability
- Results only available synchronously
- WebSocket required for task completion

---

## 5. Outcome-Based Instructions

**What to look for:**
- High-level task descriptions in docs/comments
- Acceptance criteria definitions
- Constraint specifications
- Avoiding step-by-step micromanagement
- Clear success/failure criteria

**Evidence of good implementation:**
- README describes WHAT, not HOW
- Task interfaces accept goals, not procedures
- Validation based on outcomes
- Flexibility in execution approach

**Red flags:**
- Overly prescriptive documentation
- Hardcoded execution sequences
- No room for agent judgment
- Step-by-step mandatory procedures

---

## 6. Direct Low-Level Interfaces

**What to look for:**
- CLI tools and scripts
- Direct filesystem access patterns
- Simple HTTP/network interfaces
- Process execution capabilities
- Standard I/O patterns

**Evidence of good implementation:**
- Shell scripts for operations
- Direct file read/write without abstraction
- Simple REST APIs
- OS primitive usage (processes, signals, files)

**Red flags:**
- Deep abstraction layers hiding primitives
- No command-line interface
- Overly complex API wrappers
- Proprietary protocols required

---

## 7. Minimal Framework Overhead

**What to look for:**
- Simple, explicit interfaces
- Avoiding complex orchestration frameworks
- CLI-first design
- Direct tool composition
- Minimal indirection

**Evidence of good implementation:**
- Operations reduce to: run commands, read/write files, make HTTP calls
- No heavy framework dependencies for basic operations
- Composable CLI tools
- Shell-scriptable operations

**Red flags:**
- Complex agent frameworks
- Heavy MCP dependencies for basic tasks
- Abstraction more complex than the task
- Framework lock-in

---

## 8. Explicit State Persistence

**What to look for:**
- Workspace directory patterns
- Intermediate result storage
- Log file management
- Planning artifact storage
- Checkpoint mechanisms

**Evidence of good implementation:**
- Writable workspace per task
- Intermediate results saved to files
- Logs are persistent and inspectable
- State can be examined post-run

**Red flags:**
- Purely in-memory state
- No persistent logging
- Lost context between steps
- No workspace isolation

---

## 9. Early Benchmarks

**What to look for:**
- Test suites with quality metrics
- Benchmark scripts
- Performance tests
- Evaluation frameworks
- Success criteria in tests

**Evidence of good implementation:**
- Benchmarks exist and run in CI
- Quality metrics defined early
- Comparison baselines established
- Measurable acceptance criteria

**Red flags:**
- No automated quality checks
- Benchmarks as afterthought
- Subjective quality assessment only
- No baseline comparisons

---

## 10. Cost Planning

**What to look for:**
- Rate limiting configuration
- Resource quotas
- Token/API usage tracking
- Cost monitoring setup
- Explicit limit enforcement

**Evidence of good implementation:**
- Configured resource limits
- Usage tracking/logging
- Budget alerts or caps
- Explicit provisioning for autonomous usage

**Red flags:**
- No resource limits
- Unbounded API calls
- No cost visibility
- Ad-hoc usage management

---

## 11. Verifiable Output

**What to look for:**
- Output validation logic
- Result verification tests
- Artifact integrity checks
- Deterministic output patterns
- Success/failure signals

**Evidence of good implementation:**
- Automated output verification
- Clear success/failure exit codes
- Verifiable artifacts produced
- Results can be validated without human review

**Red flags:**
- Unverifiable outputs
- Requires human judgment for success
- No validation pipeline
- Ambiguous completion states

---

## 12. Infrastructure-Bounded Permissions

**What to look for:**
- Permission configurations (IAM, RBAC)
- Capability restrictions
- Sandbox permission policies
- Least-privilege patterns
- Environment-enforced boundaries

**Evidence of good implementation:**
- Permissions defined at infrastructure level
- Explicit capability grants
- Sandbox restricts dangerous operations
- No runtime permission decisions

**Red flags:**
- All-or-nothing permissions
- Runtime permission prompts required
- No infrastructure-level constraints
- Agent self-manages permissions
