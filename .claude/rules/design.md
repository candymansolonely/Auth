# Design — Clean Architecture layering

Four projects, all targeting `net9.0`. Dependency direction is strictly inward:

```
WebAPI → Infrastructure, Application → Domain
```

- **Domain** — no project references, period. Entities, value objects, domain logic,
  domain events. Nothing outside this layer (no ASP.NET, no EF Core, no HTTP types)
  should leak in.
- **Application** — references `Domain` only. Use cases / business logic, plus the
  interfaces that `Infrastructure` will implement (repositories, external services,
  clock, password hasher, token issuer, etc.). Interfaces here must not leak
  `Infrastructure`-specific types (e.g. a specific ORM's `DbContext`, EF entities,
  HTTP request/response types) into their signatures.
- **Infrastructure** — references `Domain` and `Application`. Concrete implementations
  of the interfaces defined in `Application` (persistence, external integrations,
  email/SMS providers, etc.).
- **WebAPI** — references `Application` and `Infrastructure`. Composition root: the
  only place `Infrastructure` concretes get wired up (DI registration in `Program.cs`).
  Controllers/endpoints should be thin — validate input, call into `Application`,
  map the result to an HTTP response. No business logic here.

## Red flags to catch in review
- A `ProjectReference` or `using` that points outward (e.g. `Domain` referencing
  `Application`, or `Application` referencing `Infrastructure`).
- Business rules implemented directly in a controller or in an `Infrastructure` class
  instead of `Domain`/`Application`.
- An `Application` interface whose signature exposes an `Infrastructure` type.
- Anemic domain models where all logic lives in "service" classes in `Application`
  instead of on the entities/value objects themselves, when the logic is genuinely
  about domain invariants.
