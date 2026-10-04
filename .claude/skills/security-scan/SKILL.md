---
name: security-scan
description: Scan the AuthenAtho solution for known-vulnerable NuGet packages and formatting/lint issues. Use before a PR, after adding/updating a dependency, or when the user asks for a security check on the .NET code.
---

Run `scan.sh` (next to this file) from the repo root. It:
1. Restores the solution so the NuGet lock/metadata is current.
2. Runs `dotnet list package --vulnerable --include-transitive` across every project
   and fails loudly if any vulnerable package is found.
3. Runs `dotnet format --verify-no-changes` to catch formatting drift.

Report any vulnerable package with its severity and the advisory URL `dotnet` prints,
and suggest the minimum version bump that resolves it. This is a code-level dependency
scan, not a full pentest — it doesn't replace `/code-review` or `/security-review`.
