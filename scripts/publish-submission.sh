#!/usr/bin/env bash
set -euo pipefail
source_dir="$(cd "$(dirname "$0")/.." && pwd)"
destination="${1:-${source_dir}-submission}"
branch="submission/68030263-20261015"
if test -e "$destination"; then
  echo "Destination already exists: $destination. Choose a new path as the first argument."
  exit 1
fi
git clone https://github.com/wasuratsomdet9009/Restaurant-Management-System-Exam-2025.git "$destination"
git -C "$destination" checkout -b "$branch"
python3 - "$source_dir" "$destination" <<'PYCODE'
import sys, shutil
from pathlib import Path
src,dst=map(Path,sys.argv[1:])
# Copy only source/config and selected safe evidence. Never copy .env or full Newman JSON.
files=['Exam-Result.md','SOURCE-PROVENANCE.md','START-HERE.md','README.md','docker-compose.yml','render.yml','.env.example','.gitignore']
for part in ['backend','frontend','scripts','tests/postman','.github/workflows']:
 for p in (src/part).rglob('*'):
  if not p.is_file():continue
  rel=p.relative_to(src)
  if any(x in {'node_modules','dist','.git','.test-tools','.vite','coverage'} for x in rel.parts):continue
  if p.name.startswith('.env') and p.name!='.env.example':continue
  if p.name=='.DS_Store':continue
  files.append(str(rel))
r='tests/reports/20261014T181929Z-72752'
for name in ['measured-results.json','measured-results.html','newman-summary.md','unit-tests.log','compose-status.log','health.log','backend-audit-after.log','frontend-audit-after.log']:
 files.append(r+'/'+name)
for f in files:
 p=src/f
 if p.is_file():
  q=dst/f;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
# The old workflow duplicates the new pipeline and may use stale tests.
old=dst/'.github/workflows/ci.yml'
if old.is_file():old.unlink()
PYCODE
git -C "$destination" add backend frontend scripts tests/postman .github/workflows Exam-Result.md SOURCE-PROVENANCE.md START-HERE.md README.md docker-compose.yml render.yml .env.example .gitignore
git -C "$destination" add -f tests/reports/20261014T181929Z-72752/measured-results.json tests/reports/20261014T181929Z-72752/measured-results.html tests/reports/20261014T181929Z-72752/newman-summary.md tests/reports/20261014T181929Z-72752/unit-tests.log tests/reports/20261014T181929Z-72752/compose-status.log tests/reports/20261014T181929Z-72752/health.log tests/reports/20261014T181929Z-72752/backend-audit-after.log tests/reports/20261014T181929Z-72752/frontend-audit-after.log
git -C "$destination" diff --cached --stat
git -C "$destination" commit -m "Add 68030263 measured tests, audit remediation and deployment configuration"
git -C "$destination" push -u origin "$branch"
printf '\nPublished: https://github.com/wasuratsomdet9009/Restaurant-Management-System-Exam-2025/tree/%s\n' "$branch"
printf 'Local checkout: %s\n' "$destination"
