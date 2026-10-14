import fs from 'node:fs';
const input = process.argv[2] || 'tests/reports/newman.json';
const output = process.argv[3] || 'tests/reports/newman-summary.md';
const data = JSON.parse(fs.readFileSync(input, 'utf8'));
const stats = data.run.stats.assertions;
const executions = data.run.executions.filter(e => /^TC-/.test(e.item.name));
let passed=0, failed=0, blocked=0;
const rows=executions.map(e => {
 const a=e.assertions || [];
 const status = e.requestError || !e.response || !a.length ? 'Blocked' : a.some(x=>x.error) ? 'Fail' : 'Pass';
 if(status==='Pass')passed++; else if(status==='Fail')failed++; else blocked++;
 return '| '+e.item.name.replaceAll('|','/')+' | '+(e.response?.code ?? 'No response')+' | '+status+' |';
});
const pct=(n,d)=>d ? (100*n/d).toFixed(2)+'%' : 'N/A';
fs.writeFileSync(output, '# Newman measured results\n\nAssertions: '+(stats.total-stats.failed)+'/'+stats.total+' passed ('+pct(stats.total-stats.failed,stats.total)+').\n\nExecuted cases: '+executions.length+'; passed '+passed+'; failed '+failed+'; blocked '+blocked+'. Case pass rate including blocked: '+pct(passed,executions.length)+'.\n\nThese are executed cases only; compare with the planned suite to detect unexecuted requests.\n\n| Case | HTTP | Result |\n|---|---|---|\n'+rows.join('\n')+'\n');
