# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Run all commands from the repo root (where `AuthenAtho.slnx` lives).

```bash
dotnet build                              # build entire solution
dotnet run --project WebAPI               # run the API (see WebAPI/Properties/launchSettings.json for ports)
dotnet watch --project WebAPI run         # run with hot reload
dotnet test                               # run all tests (no test project exists yet)
dotnet test --filter "FullyQualifiedName~ClassName.MethodName"   # run a single test, once test projects exist
```

There is no `.sln` file — `AuthenAtho.slnx` is the new XML-based solution format. `dotnet sln`, `dotnet build`, and `dotnet test` all accept it directly.

## Architecture

Clean Architecture layering across 4 projects, all targeting `net9.0`:

- **Domain** — no project references. Entities, value objects, domain logic. Nothing outside this layer should leak in.
- **Application** — references `Domain`. Use cases / business logic, interfaces for infrastructure concerns (repositories, external services) that `Infrastructure` will implement.
- **Infrastructure** — references `Domain` and `Application`. Concrete implementations of the interfaces defined in `Application` (persistence, external integrations, etc.).
- **WebAPI** — references `Application` and `Infrastructure` (`Microsoft.NET.Sdk.Web`, ASP.NET Core controllers). Composition root: this is the only place `Infrastructure` should be wired up (DI registration in `Program.cs`).

Dependency direction is strictly inward: `WebAPI` → `Infrastructure`/`Application` → `Domain`. `Domain` and `Application` must never reference `Infrastructure` or `WebAPI`.

The solution is currently a bare scaffold: `Domain`, `Application`, and `Infrastructure` are empty class libraries, and `WebAPI` still has the default ASP.NET Core template (`WeatherForecastController`, minimal `Program.cs` with controllers + OpenAPI). When adding features, place them in the appropriate layer per the rules above rather than putting logic directly in `WebAPI`.

## Plans

Non-trivial features get a plan file under `plans/` before implementation (see `plans/README.md` for the expected shape). Check there for existing context before starting work on a feature.

## Specialized subagents

`.claude/agents/` defines subagents for the different modes of work on this repo — dispatch to the one matching the task instead of doing everything as the general-purpose agent:

- **business-analyst** — read-only. Research/clarify business requirements and write them up as a plan in `plans/`.
- **coder** — implements features/fixes across the four layers.
- **tester** — writes/runs unit and integration tests.
- **reviewer** — read-only. Reviews diffs for correctness and layering violations.
