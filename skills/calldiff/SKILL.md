---
name: calldiff
description: "Call-graph evidence from git via the calldiff CLI: which functions reach a symbol, and how a change moved the call structure. Use when you need blast radius before editing (does anything reach this function, and by what path), when scoping which files a change really touches, or when reviewing a diff whose risk is structural rather than textual. Tree-sitter based, 22 languages, no build step. Do not use it as a general replacement for git diff."
---

# calldiff

`calldiff` answers "who calls whom", read straight from a git tree. It is
syntactic (tree-sitter, no type checking), so it is fast and needs no build,
and it will miss dynamic dispatch. Treat its output as evidence that narrows
attention — never as proof that nothing else is affected.

Installed globally: run `calldiff`, not `npx calldiff`.

## The three modes worth using

| command | use for |
|---|---|
| `calldiff reach --entry <fn> --to <symbol> --locs` | blast radius. Every call path from an entrypoint down to a target, each hop with `file:line`. Use before editing a shared function, and to answer "can this change reach X". |
| `calldiff diff --file <path>` | structural review of one changed file: which calls this change added, removed, or swapped, shown in tree context. |
| `calldiff tree --file <path>` | a call outline of one module, when you need its shape before reading it. |

Add `--max-depth <n>` when a tree runs long. `--locs` is cheap and almost
always worth it — line numbers make the output actionable.

## Do not run bare `calldiff diff`

It reprints whole unchanged call trees around every change. Measured on a
mid-size React monorepo: **36k tokens, versus ~18k for the raw `git diff`** —
double the cost for less information. Positional path scoping (`diff HEAD
<path>`) silently returned nothing in the same test; do not rely on it.

Scope with `--file` or `--entry`, one target at a time. When output size is
uncertain, preflight it:

```sh
calldiff diff --file <path> --token-count
```

## Where this earns its place

- **Before editing a shared helper** — `reach` from the app entrypoint tells
  you which callers exist and where, in seconds, instead of a Grep sweep.
- **Scoping a review** — drive `diff --file` from the changed-file list
  (`git diff --name-only`), not across the whole repo.
- **Framework noise is real.** In React code every `useState()` and `useRef()`
  counts as a call, so component trees are mostly noise. calldiff is most
  useful on plain modules of named functions, least useful on component trees.

## Where it does not help

Dynamic dispatch, higher-order functions, DI containers, and hook indirection
do not resolve. If the answer must be complete, calldiff is a starting point
and not the answer. Say so when you report what it found.

Other output formats (`--format json|md`) and an MCP mode exist; the CLI text
output is the right default for reading and for pasting into a review.
