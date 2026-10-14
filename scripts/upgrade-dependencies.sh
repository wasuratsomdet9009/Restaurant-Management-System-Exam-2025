#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
backup="tests/reports/dependency-upgrade-$run_id"
mkdir -p "$backup/backend" "$backup/frontend"
cp backend/package*.json "$backup/backend/"
cp frontend/package*.json frontend/postcss.config.js "$backup/frontend/"
cp frontend/src/index.css "$backup/frontend/index.css"
# Versions suggested by measured audit; install explicitly instead of --force.
(cd backend && npm update)
(cd frontend && npm install react-router-dom@7.18.4)
(cd frontend && npm install --save-dev vite@8.3.4 @vitejs/plugin-react@latest tailwindcss@4.3.3 @tailwindcss/postcss@4.3.3 postcss@latest)
node --input-type=module <<'JS'
import fs from 'node:fs';
fs.writeFileSync('frontend/postcss.config.js', `export default { plugins: { '@tailwindcss/postcss': {} } }\n`);
let css=fs.readFileSync('frontend/src/index.css','utf8');
css=css.replace(/@tailwind base;\s*@tailwind components;\s*@tailwind utilities;/, '@import "tailwindcss";\n@config "../tailwind.config.js";');
// Shared custom classes must be registered as utilities for @apply in v4.
for (const name of ['btn','badge']) {
 const pattern=new RegExp('\\.'+name+'\\s*\\{([^}]+)\\}');
 const match=css.match(pattern);
 if(match) { css=css.replace(pattern,''); css+='\n@utility '+name+' {'+match[1]+'}\n'; }
}
fs.writeFileSync('frontend/src/index.css',css);
JS
(cd backend && npx prisma generate && npm run build)
(cd frontend && npm run build)
printf 'Original files backed up in %s\n' "$backup"
bash scripts/finish-local.sh --fix-dependencies
