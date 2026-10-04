#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../../.."

echo "==> dotnet restore"
dotnet restore AuthenAtho.slnx

echo "==> dotnet list package --vulnerable --include-transitive"
if dotnet list AuthenAtho.slnx package --vulnerable --include-transitive 2>&1 | tee /tmp/security-scan-vuln.txt | grep -qi "has the following vulnerable packages"; then
  echo
  echo "Vulnerable packages found:"
  cat /tmp/security-scan-vuln.txt
  exit 1
fi

echo "==> dotnet format --verify-no-changes"
dotnet format AuthenAtho.slnx --verify-no-changes

echo "No known-vulnerable packages found; formatting is clean."
