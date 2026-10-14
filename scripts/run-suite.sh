#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
mkdir -p tests/reports
# Do not summarize a previous run if Newman fails before exporting JSON.
if test -f tests/reports/newman.json; then
  mv tests/reports/newman.json "tests/reports/newman.previous.$(date -u +%Y%m%dT%H%M%SZ)-$$.json"
fi
newman run tests/postman/RMS-68030263-TestSuite.json \
  -e tests/postman/env.json \
  --reporters cli,json,htmlextra \
  --reporter-json-export tests/reports/newman.json \
  --reporter-htmlextra-export tests/reports/newman.html \
  --reporter-htmlextra-skipSensitiveData
result=$?
if test -f tests/reports/newman.json; then node scripts/summarize-newman.mjs; fi
exit "$result"
