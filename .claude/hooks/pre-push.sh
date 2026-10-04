#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

echo "[pre-push] dotnet test"
dotnet test AuthenAtho.slnx --nologo -v quiet
