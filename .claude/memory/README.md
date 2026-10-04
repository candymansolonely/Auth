# memory/

Project-local memory notes that should persist across sessions and be shared with the
team via git — distinct from personal scratch notes (`CLAUDE.local.md`) and from any
per-user memory a Claude Code instance keeps outside the repo.

Use this directory for durable, project-specific context that isn't obvious from the
code itself, e.g.:
- Architectural decisions and the reasoning behind them (ADR-style notes)
- Known gotchas or footguns discovered while working in this codebase
- Summaries of past incidents/bugs and their root causes

Keep entries short and dated. One file per topic (e.g. `2026-10-auth-flow-decision.md`)
rather than one growing file.
