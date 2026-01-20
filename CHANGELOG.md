# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `changelog-update` hook to prompt for changelog updates before commits

## [2026-01-20]

### Changed
- General updates and improvements

## [2026-01-16]

### Added
- `claude-md-author` skill for creating project-specific CLAUDE.md files
- `capture-learning` skill for documenting learnings to CLAUDE.md or skills
- MCP config symlink support in setup script
- MCP configuration for OpenAI Developer Docs

### Changed
- Updated clone URL in README
- Updated permissions configuration

## [2026-01-15]

### Added
- `swiftui-excellence` skill for Apple-level SwiftUI interfaces
- `macos-app-design` skill with comprehensive reference guide
- `rust-engineering` skill for robust Rust patterns

### Changed
- Synced settings.json to repo
- Updated interview command

### Fixed
- Fixed plugins configuration

## [2026-01-11]

### Added
- `tuning-panel` command/skill for parameter GUI creation

### Changed
- Updated record-todos command
- Updated README

## [2026-01-07]

### Added
- `say-ready` hook for audio notifications when Claude is ready
- `say-ready.sh` script for spoken notifications
- `doc-update-check` hook for self-maintaining documentation
- `record-todos` command for capturing ideas without acting
- Global commands support
- `~/Code` to additionalDirectories

### Changed
- Updated for new Claude version
- Updated record-todos prompt
- Updated gitignore to stop tracking `.claude/hud-status.json`
- Improved developer experience for new users
- Removed hardcoded `~/Code` path from docs
- Noted self-maintaining docs pattern in README

### Removed
- Unused session-start-notify hook script

## [2026-01-05]

### Added
- `react-component-dev` skill for React patterns, forwardRef, accessibility
- `pre-commit-verify` hook for verification reminders
- Statusline configuration
- Templates for settings and MCP configuration
- FORKING.md guide for customization

### Changed
- Made repo forkable for others
- Cleaned up stale files and synced settings

## [2026-01-04]

### Added
- Additional skill files and configurations

## [2025-12-27]

### Added
- `nextjs-boilerplate` skill for Next.js + Tailwind + shadcn/ui setup
- `wise-novice` skill for fresh perspectives and naive questions
- `design-critique` skill for UI/UX reviews with severity ratings
- Interaction design resources (Direct Manipulation, Instrumental Interaction papers)
- Cognitive psychology resources (Feature-Integration Theory, Judgment under Uncertainty)
- `sync-skills.sh` script for syncing skills directory
- `validate.sh` script for frontmatter validation
- Comprehensive skills table to README

### Changed
- Renamed "Healthy Skepticism" to `stress-testing`
- Enhanced `unix-macos-engineer` skill with quick command patterns
- Revised `typography` and `ux-writing` skills
- Updated cognitive foundations skill with cognitive load considerations
- Refactored README for clarity and readability
- Renamed project to "Claude Code Setup"

## [2025-12-26]

### Added
- `model-first-reasoning` skill for formal logic and state machines
- `cognitive-foundations` skill for user psychology and HCI research
- `interaction-design` skill for component behaviors and micro-interactions
- `dreaming` skill for expansive thinking and breaking constraints
- `oss-product-manager` skill for open source strategy
- `startup-wisdom` skill for product strategy and PMF
- `typography` skill for type scales and hierarchy
- `ux-writing` skill for microcopy and error messages

### Changed
- Renamed skills to use consistent naming convention

### Removed
- `successful-repeat-founder` skill (consolidated into `startup-wisdom`)
