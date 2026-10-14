#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p tests/reports
# Preserve previous evidence; each invocation records its own status.
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
report_dir="tests/reports/$run_id"
mkdir -p "$report_dir"
failed=0
fix_dependencies=0
case "${1:-}" in
  "") ;;
  --fix-dependencies) fix_dependencies=1 ;;
  *) echo 'Usage: bash scripts/finish-local.sh [--fix-dependencies]'; exit 2 ;;
esac
if ! docker info >"$report_dir/docker-info.log" 2>&1; then
  echo 'Docker is not accessible. Start Docker Desktop and run this in a terminal with Docker access.'
  echo "Diagnostic: $report_dir/docker-info.log"
  exit 1
fi
if ! curl --fail --silent --show-error --connect-timeout 10 --max-time 20 https://registry.npmjs.org/-/ping >"$report_dir/network.log" 2>&1; then
  echo "npm registry is unreachable. Diagnostic: $report_dir/network.log"
  exit 1
fi
if ! test -f .env; then
  node -e 'const fs=require("fs"),c=require("crypto");fs.writeFileSync(".env","POSTGRES_PASSWORD="+c.randomBytes(24).toString("hex")+"\nJWT_SECRET="+c.randomBytes(32).toString("hex")+"\n",{mode:0o600})'
fi
run_record() {
  local label="$1"; shift
  set +e
  "$@" > "$report_dir/${label}.log" 2>&1
  local code=$?
  last_code=$code
  set -e
  printf '%s\t%s\n' "$label" "$code" >> "$report_dir/execution-status.tsv"
  printf '%s: exit %s\n' "$label" "$code"
  if test "$code" -ne 0; then failed=1; fi
  return 0
}
: > "$report_dir/execution-status.tsv"
for component in backend frontend; do
  run_record "${component}-install" bash -c 'cd "$1" && npm ci' _ "$component"
  test "$last_code" -eq 0 || exit 1
  previous_failed=$failed
  run_record "${component}-audit-before" bash -c 'cd "$1" && npm audit --json --audit-level=moderate' _ "$component"
  failed=$previous_failed
  if test "$fix_dependencies" -eq 1; then
    run_record "${component}-audit-fix" bash -c 'cd "$1" && npm audit fix' _ "$component"
  fi
  run_record "${component}-audit-after" bash -c 'cd "$1" && npm audit --json --audit-level=moderate' _ "$component"
done
(cd backend && npx prisma generate && npm run build)
(cd frontend && npm run build)
run_record unit-tests bash -c 'cd backend && NODE_ENV=test npm test'
docker compose up --build -d --wait --wait-timeout 240
run_record compose-status docker compose ps
run_record health curl --fail --silent --show-error http://localhost:3001/api/health
if ! command -v newman >/dev/null; then
  npm install --prefix .test-tools --no-audit --no-fund newman@6 newman-reporter-htmlextra@1
  export PATH="$PWD/.test-tools/node_modules/.bin:$PATH"
fi
run_record newman bash scripts/run-suite.sh
if test -f tests/reports/newman.json; then
  cp tests/reports/newman.json "$report_dir/"
fi
printf '\nEvidence is in tests/reports. Review failures and update Exam-Result.md; this does not claim deployment completion.\n'
printf 'Open http://localhost for the staging login and capture the required evidence.\n'

printf "Run evidence: %s\n" "$report_dir"
exit "$failed"
