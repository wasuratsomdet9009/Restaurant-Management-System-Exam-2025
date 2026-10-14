import fs from 'node:fs';
import vm from 'node:vm';
import {stripTypeScriptTypes} from 'node:module';
import {createHash} from 'node:crypto';
const records=[];
// Execute the supplied route bodies, replacing ONLY external imports with mocks.
// This is an in-process logic test, not HTTP, JWT, PostgreSQL, or Newman evidence.
async function exercise(file, method, route, body, prisma, expected, name) {
 const original=fs.readFileSync(file,'utf8');
 const registrations=[];
 const router=Object.fromEntries(['get','post','put','delete'].map(m=>[m,(path,...handlers)=>registrations.push({method:m,path,handlers})]));
 const authenticate=(_req,_res,next)=>next();
 const requireRole=(...roles)=>(req,res,next)=>roles.includes(req.user.role)?next():res.status(403).json({error:'denied by role mock'});
 const source=stripTypeScriptTypes(original).replace(/^import .*$/gm,'').replace('export default router','');
 vm.runInNewContext(source,{Router:()=>router,prisma,authenticate,requireRole,console});
 const found=registrations.find(x=>x.method===method&&x.path===route);
 const req={body,params:{id:'1'},query:{},user:{id:1,role:'cashier'}};
 const res={statusCode:200,body:null,status(n){this.statusCode=n;return this;},json(x){this.body=x;return this;}};
 let index=0;const next=async()=>{const h=found.handlers[index++];if(h)await h(req,res,next);};await next();
 records.push({name,source:file,sha256:createHash('sha256').update(original).digest('hex'),input:body,expectedStatus:expected,actualStatus:res.statusCode,response:res.body,result:res.statusCode===expected?'Pass':'Fail',scope:'In-process route with mocked dependencies; no HTTP server/database/JWT'});
}
function paymentDB(status='confirmed') {return {order:{findUnique:async()=>({id:1,tableId:1,status,totalAmount:160,items:[{id:1}]}),update:async({data})=>data},payment:{create:async({data})=>data},restaurantTable:{update:async({data})=>data},$transaction:async ps=>Promise.all(ps)};}
await exercise('backend/src/routes/payments.ts','post','/',{orderId:1,amountPaid:200},paymentDB(),201,'Overpayment accepted');
await exercise('backend/src/routes/payments.ts','post','/',{orderId:1,amountPaid:160},paymentDB(),201,'Exact payment accepted');
await exercise('backend/src/routes/payments.ts','post','/',{},paymentDB(),400,'Missing input rejected');
await exercise('backend/src/routes/payments.ts','post','/',{orderId:1,amountPaid:200},paymentDB('paid'),400,'Duplicate payment rejected');
await exercise('backend/src/routes/payments.ts','post','/',{orderId:1,amountPaid:100},paymentDB(),400,'BUG-001 Underpayment must be rejected');
let creates=0;
const db={restaurantTable:{findUnique:async()=>({id:1,status:'occupied'}),update:async({data})=>data},order:{findFirst:async()=>({id:99,status:'open',tableId:1}),create:async({data})=>({id:++creates,...data})},$transaction:async ps=>Promise.all(ps)};
await exercise('backend/src/routes/orders.ts','post','/',{tableId:1},db,409,'BUG-002 Occupied table must reject duplicate order');
const result={runAt:new Date().toISOString(),node:process.version,scope:'Mock-based route logic only, NOT Newman or database integration',total:records.length,passed:records.filter(x=>x.result==='Pass').length,failed:records.filter(x=>x.result==='Fail').length,records};
fs.mkdirSync('tests/reports',{recursive:true});fs.writeFileSync('tests/reports/route-logic.json',JSON.stringify(result,null,2));
console.log(JSON.stringify(result,null,2));
process.exitCode=result.failed?1:0;
