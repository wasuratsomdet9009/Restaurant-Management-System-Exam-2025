#!/usr/bin/env bash
set -euo pipefail
source_dir="$(cd "$(dirname "$0")/.." && pwd)"
destination="${1:?Usage: bash scripts/prepare-submission.sh /absolute/new/clone/path}"
test ! -e "$destination" || { echo "Destination already exists; choose a new path."; exit 1; }
git clone https://github.com/surachai-p/Restaurant-Management-System-Exam-2025.git "$destination"
rsync -a --exclude=.git --exclude=node_modules --exclude=dist --exclude=.env --exclude='.env.*' --include='.env.example' "$source_dir/" "$destination/"
# .env.example files are safe templates; copy explicitly after secret exclusions.
cp "$source_dir/.env.example" "$destination/.env.example"
cp "$source_dir/backend/.env.example" "$destination/backend/.env.example"
cp "$source_dir/frontend/.env.example" "$destination/frontend/.env.example"
rm -f "$destination/.github/workflows/ci.yml"
cd "$destination"
git remote rename origin upstream
echo "Instructor history retained. Review git diff; create your own repository, add origin, then commit and push."
git status --short
