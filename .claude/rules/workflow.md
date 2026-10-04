# Workflow

- Run all commands from the repo root, where `AuthenAtho.slnx` lives.
- Non-trivial features get a plan file under `plans/` before implementation — check
  `plans/README.md` for the expected shape, and check `plans/` for existing context
  before starting work on a feature.
- Dispatch to the specialized subagent that matches the task instead of doing
  everything as the general-purpose agent:
  - **business-analyst** — research/clarify business requirements, write them up as a
    plan in `plans/`. Read-only.
  - **researcher** — technical research (library choices, security standards, prior
    art) that informs a plan or implementation decision. Read-only.
  - **coder** — implements features/fixes across Domain/Application/Infrastructure/WebAPI.
  - **tester** — writes and runs unit/integration tests.
  - **reviewer** — reviews diffs for correctness and layering violations. Read-only.
- Before committing: `dotnet build` must succeed and `dotnet test` must pass (once
  test projects exist).
- Only create git commits when the user explicitly asks for one. Never `--force` push
  or skip hooks (`--no-verify`) without explicit instruction.
- Keep changes scoped to the layer the task actually touches — don't opportunistically
  refactor unrelated code in the same commit.
