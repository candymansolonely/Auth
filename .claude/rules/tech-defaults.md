# Tech defaults

No library choices are locked in yet beyond the default ASP.NET Core template
(`Microsoft.AspNetCore.OpenApi`). When a feature needs a new dependency, prefer the
following unless the user says otherwise — and ask before adding a dependency that
isn't on this list.

- **Target framework**: `net9.0` everywhere (already set in all four `.csproj`).
- **Testing**: xUnit + `Microsoft.NET.Test.Sdk`, one test project per layer that needs
  coverage (e.g. `Application.Tests`, `Domain.Tests`), referencing only the layer(s)
  under test plus `Domain`.
- **Persistence**: Entity Framework Core in `Infrastructure`, behind repository
  interfaces declared in `Application`. Don't let `DbContext` or EF entity types leak
  into `Application` or `Domain`.
- **Auth/tokens**: JWT bearer tokens (`Microsoft.AspNetCore.Authentication.JwtBearer`)
  wired up in `WebAPI`; token issuing logic lives behind an `Application` interface
  implemented in `Infrastructure`.
- **Password hashing**: ASP.NET Core Identity's `PasswordHasher<T>`, or a dedicated
  interface in `Application` implemented with BCrypt/Argon2 in `Infrastructure` if
  Identity itself isn't adopted wholesale.
- **Validation**: FluentValidation in `Application` for use-case input validation,
  rather than hand-rolled `if` chains.
- **Logging**: built-in `Microsoft.Extensions.Logging` abstractions; don't introduce
  Serilog/NLog unless there's a concrete need (structured sinks, etc.).
- **Nullable reference types**: enabled everywhere — keep it that way, don't suppress
  warnings with `!` unless genuinely unavoidable.
