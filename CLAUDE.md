# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Tech Stack

- .NET 9 (`net9.0`) + ASP.NET Core
- Clean Architecture: Domain / Application / Infrastructure / WebAPI
- Entity Framework Core cho persistence (mặc định đề xuất, chưa có DB cụ thể được chọn — xem `.claude/rules/tech-defaults.md`)
- JWT bearer (`Microsoft.AspNetCore.Authentication.JwtBearer`) cho authentication
- xUnit + Moq/NSubstitute cho unit test, `WebApplicationFactory` cho integration test (chưa có test project nào)
- FluentValidation cho validate input ở Application layer
- `Microsoft.Extensions.Logging` (ILogger) cho logging

Không tự ý thêm dependency ngoài danh sách trên — hỏi trước, hoặc xem `.claude/rules/tech-defaults.md`.

## Commands

Run all commands from the repo root (where `AuthenAtho.slnx` lives).

```bash
dotnet build                              # build entire solution
dotnet run --project WebAPI               # run the API (see WebAPI/Properties/launchSettings.json for ports)
dotnet watch --project WebAPI run         # run with hot reload
dotnet test                               # run all tests (no test project exists yet)
dotnet test --filter "FullyQualifiedName~ClassName.MethodName"   # run a single test, once test projects exist
dotnet format                             # format theo .editorconfig
```

There is no `.sln` file — `AuthenAtho.slnx` is the new XML-based solution format. `dotnet sln`, `dotnet build`, and `dotnet test` all accept it directly.

## Architecture

Clean Architecture layering across 4 projects, all targeting `net9.0`. Dependency direction strictly inward:

```
WebAPI → Infrastructure, Application → Domain
```

- **Domain** — no project references. Entities, value objects, domain logic. Nothing outside this layer should leak in.
- **Application** — references `Domain` only. Use cases / business logic, interfaces cho infrastructure concerns (repositories, external services) mà `Infrastructure` sẽ implement.
- **Infrastructure** — references `Domain` và `Application`. Concrete implementations của các interface định nghĩa trong `Application` (persistence, external integrations, etc.).
- **WebAPI** — references `Application` và `Infrastructure` (`Microsoft.NET.Sdk.Web`, ASP.NET Core controllers). Composition root: nơi duy nhất `Infrastructure` được wire up (DI registration trong `Program.cs`).

`Domain` và `Application` không bao giờ được reference `Infrastructure` hay `WebAPI`. Chi tiết và các red flag cần bắt khi review nằm ở `.claude/rules/design.md`.

The solution is currently a bare scaffold: `Domain`, `Application`, and `Infrastructure` are empty class libraries, and `WebAPI` still has the default ASP.NET Core template (`WeatherForecastController`, minimal `Program.cs` with controllers + OpenAPI).

## Cấu trúc thư mục

- `Domain/` — Entities, value objects, domain logic, domain events. Không có project reference nào ra ngoài.
- `Application/` — Use cases (CQRS handlers hoặc service theo nhu cầu), interfaces cho repository/external service, DTOs cho request/response, validators (FluentValidation), custom exceptions của tầng nghiệp vụ.
- `Infrastructure/` — EF Core `DbContext` + migrations, repository implementations, external integrations (email, token issuer, password hasher, v.v.).
- `WebAPI/` — Controllers (mỏng, không chứa business logic), `Program.cs` (composition root), `appsettings*.json`, exception handling middleware tập trung.
- `plans/` — plan file cho các feature không nhỏ (xem `plans/README.md`).

## Quy tắc code

- Theo layered/Clean Architecture: Controller → Application (use case) → Domain/Infrastructure qua interface.
- Dùng constructor injection, không dùng service locator hay static singleton để lấy dependency.
- Mỗi public method ở Application (use case/service) nên có unit test tương ứng.
- Exception handling tập trung qua middleware (`UseExceptionHandler` hoặc filter chung), không bắt lỗi rải rác trong từng controller.
- Logging bằng `ILogger<T>` (dependency injection), không dùng `Console.WriteLine`.
- Nullable reference types bật ở tất cả project — không suppress bằng `!` trừ khi thực sự không tránh được.
- Interface trong `Application` không được để lộ type của `Infrastructure` (EF entity, `DbContext`, v.v.) ra ngoài signature.

## Quy trình làm việc

1. Trước khi code: `dotnet build` để chắc solution compile được.
2. Trước khi commit: `dotnet test` (và `dotnet format` để check style) — xem `.claude/hooks/pre-commit.sh` / `pre-push.sh`, đã wire qua `git config core.hooksPath .claude/hooks`.
3. Dùng conventional commits: `feat/fix/chore/docs/refactor/test`.
4. Non-trivial feature: viết plan trong `plans/` trước khi code (xem `plans/README.md`).
5. Dispatch đúng subagent cho từng việc — xem mục "Specialized subagents" bên dưới.

## Không được làm

- Không push `--force` hay commit thẳng lên `main` nếu chưa được yêu cầu rõ ràng.
- Không xóa EF Core migration file một khi đã có (migrations là lịch sử schema, không sửa/xóa migration đã apply).
- Không để business logic trong Controller — logic nghiệp vụ thuộc về `Domain`/`Application`.
- Không để interface của `Application` leak type của `Infrastructure` (ORM-specific, HTTP-specific) vào signature.
- Không skip git hook bằng `--no-verify` trừ khi người dùng yêu cầu rõ ràng.

## Database

Chưa chốt DB cụ thể cho project này. Mặc định đề xuất khi cần persistence: EF Core + PostgreSQL hoặc SQL Server (xem `.claude/rules/tech-defaults.md`), migration theo cơ chế EF Core (`dotnet ef migrations add {Name}` trong `Infrastructure`, apply qua `dotnet ef database update` hoặc tự động khi start app tuỳ môi trường). Cập nhật mục này khi quyết định được đưa ra.

## Plans

Non-trivial features get a plan file under `plans/` before implementation (see `plans/README.md` for the expected shape). Check there for existing context before starting work on a feature.

## Rules

`.claude/rules/` holds the detailed rules that back this file — read them before non-trivial work:

- **workflow.md** — dev workflow, subagent dispatch, commit/push conventions.
- **design.md** — Clean Architecture layering rules and the red flags a review should catch.
- **tech-defaults.md** — default libraries/choices for new dependencies (testing, persistence, auth, validation, logging).

## Memory

`.claude/memory/` holds durable, project-specific notes that aren't obvious from the code (architectural decisions, known gotchas, past incident summaries). `CLAUDE.local.md` (gitignored) is for personal, non-shared notes.

## Specialized subagents

`.claude/agents/` defines subagents for the different modes of work on this repo — dispatch to the one matching the task instead of doing everything as the general-purpose agent:

- **business-analyst** — read-only. Research/clarify business requirements and write them up as a plan in `plans/`.
- **researcher** — read-only. Technical research (library choices, security standards, prior art) that informs a plan or implementation decision.
- **coder** — implements features/fixes across the four layers.
- **tester** — writes/runs unit and integration tests.
- **reviewer** — read-only. Reviews diffs for correctness and layering violations.
- **doc-architect** — syncs `.claude/rules/` (API response/routing conventions, design patterns, RabbitMQ/Kafka/Redis usage) with what the codebase actually does. Only writes inside `.claude/` and `CLAUDE.md`, never application code.

## Skills

`.claude/skills/security-scan/` — scans for known-vulnerable NuGet packages and formatting drift; run before a PR or after touching dependencies.
