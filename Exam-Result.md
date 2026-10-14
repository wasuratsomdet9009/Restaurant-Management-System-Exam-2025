# Restaurant Management System

**ผู้จัดทำ:** นายวสุรัชต์ สมเด็จ  
**รหัสนักศึกษา:** 68030263  
**รายวิชา:** การออกแบบและพัฒนาซอฟต์แวร์ 1  
**วันที่จัดทำ:** 14 ตุลาคม 2569

> สถานะล่าสุด: build และ Docker Staging ผ่าน audit Backend/Frontend ไม่พบช่องโหว่ (0/0) Newman ผ่าน20/25 หรือ80% ยืนยันบั๊ก4รายการ Unit/APIเดิมผ่าน19/20 ภาพหลักฐาน On-Premises/Production และ Self-Hosted Runner ยังไม่ครบ

## Project Overview

ผมจัดทำแผนทดสอบระบบจัดการร้านอาหารตามข้อสอบ โดยใช้โค้ดจากรีโพสิทอรี่ของอาจารย์ ครอบคลุมการเข้าสู่ระบบ เมนู ออเดอร์ ชำระเงิน และรายงานยอดขาย ผมให้ความสำคัญกับยอดเงินที่ถูกต้องและสิทธิ์ของพนักงาน เพราะความผิดพลาดส่งผลต่อรายได้โดยตรง

ต้นฉบับ: https://github.com/surachai-p/Restaurant-Management-System-Exam-2025  
รายละเอียดแหล่งที่มาอยู่ใน [SOURCE-PROVENANCE.md](SOURCE-PROVENANCE.md)

ผมอ่านโค้ดผ่าน GitHub ได้ แต่คำสั่ง git clone บนเครื่องนี้ไม่สำเร็จเพราะ DNS ดังนั้นโฟลเดอร์นี้เป็นสำเนาซอร์ส ไม่ใช่การโคลนที่มีประวัติ Git ครบ ต้องใช้ scripts/prepare-submission.sh ก่อนสร้างคอมมิตและส่งจริง

## Tech Stack

| ส่วน | ตามโจทย์และซอร์ส | สถานะที่ตรวจได้ |
|---|---|---|
| Frontend | React18, Vite8.3.4, TypeScript, Tailwind4.3.3, React Router7.18.4 | buildผ่านหลังอัปเกรด |
| Backend | Node.js 22, Express, TypeScript | เครื่องมี Node.js 22.17.1 และ npm 11.11.0 |
| Database | PostgreSQL16 และ Prisma5.22.0 | เชื่อมฐานข้อมูลDockerและรันNewmanแล้ว |
| Unit/API | Vitest และ Supertest | ผ่าน19/20; helperเดิมไม่ใช่production route |
| Integration | Postman และ Newman | รันครบ25กรณี ผ่าน20 ไม่ผ่าน5 |
| Staging | Docker Compose | db/backend/frontend Healthy และhealthผ่าน |
| Cloud | Neon, Render, Vercel | ยังไม่ได้สร้างบริการและ URL |

เวอร์ชัน dependency ที่แน่นอนต้องยึด package-lock.json ของแต่ละส่วน ไม่ใช้เวอร์ชันในแผนแทนเวอร์ชันที่ติดตั้งจริง

## Production URLs

| รายการ | URL / สถานะปัจจุบัน |
|---|---|
| GitHub Public ของผม | https://github.com/wasuratsomdet9009/Restaurant-Management-System-Exam-2025 — รีโพสิทอรี่เดิม; งานรอบนี้ยังไม่push |
| Frontend เดิม | https://restaurant-management-system-exam-2-kappa.vercel.app — ยังไม่ตรวจเวอร์ชันปัจจุบัน |
| Backend Health เดิม | https://restaurant-management-system-exam.onrender.com/api/health — แสดงApplication loadingในการตรวจล่าสุด |

ผมยังไม่นับURLเก่าเป็นหลักฐานการdeployซอร์สรอบนี้ และไม่ใส่connection stringของฐานข้อมูลในรายงาน

## Test Plan

### ขอบเขตการทดสอบ

**In Scope:** Auth ทั้งสามบทบาท; เพิ่ม อ่าน แก้ไข และปิดเมนู; เปิดโต๊ะ เพิ่มสินค้า ยืนยันและยกเลิกออเดอร์; เงินทอน การจ่ายไม่ครบและการจ่ายซ้ำ; รายงานยอดขาย; JWT และการจำกัดสิทธิ์; health check; Docker และ CI/CD

**Out of Scope:** Payment Gateway จริง เครื่องพิมพ์ใบเสร็จจริง และโหลดระดับหลายพันผู้ใช้ เพราะโจทย์ไม่ได้ให้บริการหรืออุปกรณ์สำหรับทดสอบ ผมจะไม่ใช้ผล API แทนผลทดสอบเครื่องพิมพ์

**ช่องว่างที่พบ:** schema.prisma ไม่มีโมเดลสต็อกวัตถุดิบ จึงยังทดสอบการตัดสต็อกตามคำบรรยายโจทย์ไม่ได้ ต้องระบุเป็นข้อจำกัดของระบบ ไม่บันทึกว่าผ่าน ฟังก์ชันรายเดือนตรวจผ่านช่วงวันที่ของ /reports/sales ส่วนความถูกต้องของยอดต้องเทียบกับข้อมูล fixture เพิ่มเติม

### แนวทางการทดสอบ

1. Unit/API ด้วย Vitest เพื่อตรวจการคำนวณและ HTTP โดยใช้ mock ตามชุดเดิม
2. Integration ด้วย Postman/Newman กับ PostgreSQL 16 จริง ตรวจทั้งสถานะ HTTP และข้อมูลที่ตอบกลับ
3. Security ตรวจโทเคน สิทธิ์การแก้ราคา และ SQL injection แบบอ่านข้อมูล เฉพาะฐานข้อมูลทดสอบของผม
4. Dependency scan ด้วย npm audit ทั้ง backend และ frontend
5. Smoke test บน Local, Staging และ Production: health, login, เปิดออเดอร์และเพิ่มสินค้า, ชำระเงิน
6. แยกการตรวจโค้ดออกจากผลรันจริง โดยแนบคำสั่งและหลักฐานของแต่ละประเภท

### สภาพแวดล้อมและข้อมูลทดสอบ

Local: Backend http://localhost:3001/api, Frontend http://localhost:5173  
Staging: Frontend http://localhost, Backend http://localhost:3001/api, PostgreSQL 16 ใน Docker  
CI: Ubuntu runner, Node.js 22, PostgreSQL 16 service ที่เปิดพอร์ต 5432

ใช้ฐานข้อมูลทดสอบแยกจากข้อมูลร้านจริง บัญชี seed ได้แก่ admin, cashier1, waiter1 ชุดทดสอบสร้างเมนูชื่อ RMS 68030263 Fixture ราคา 80 บาท เลือกโต๊ะว่างและใช้ ID ที่ API ส่งกลับ ไม่ใช้เลขออเดอร์ที่คาดเดา หลังจบจะปิดเมนูทดสอบและยกเลิกออเดอร์ที่ค้าง แต่ประวัติการชำระเงินทดสอบยังอยู่ จึงห้ามรัน Collection ทั้งชุดกับข้อมูลจริง

### Entry Criteria

- ติดตั้ง dependencies, generate Prisma, สร้าง schema และ seed สำเร็จ
- API health ตอบ 200 และ status=ok
- บัญชีทั้งสามบทบาทล็อกอินได้ มีโต๊ะว่าง และฐานข้อมูลเป็นชุดทดสอบ
- กำหนด base_url ให้ตรง environment และมีชุดข้อมูลตั้งต้นที่ตรวจสอบได้

### Exit Criteria

ผมกำหนดให้ Test Cases ที่วางแผนไว้ผ่าน 100% และไม่มี Not Run หรือ Blocked ก่อนพร้อมส่งขึ้นใช้งาน ต้องไม่มีบั๊ก Critical/High ที่ยังเปิดอยู่ และ npm audit ต้องไม่พบ High/Critical ที่ยังไม่แก้ Smoke test ทั้ง 4 รายการต้องผ่านพร้อมหลักฐาน

Pass Rate ระดับกรณี = จำนวนกรณี Pass / จำนวนกรณีที่วางแผนทั้งหมด × 100  
อัตรา assertion ของ Newman คำนวณแยก ไม่ใช้แทนจำนวนกรณีทดสอบ

### Business Risk

| ความเสี่ยง | ผลกระทบ | การตรวจหลัก |
|---|---|---|
| รับเงินไม่ครบแต่ปิดบิล | ร้านสูญเสียรายได้ ยอดรับเงินจริงไม่ตรงยอดขาย | TC-021, TC-022 |
| เปิดหลายบิลบนโต๊ะเดียว | พนักงานสับสน เก็บเงินซ้ำหรือหลุดบิล | TC-015 |
| พนักงานเปลี่ยนราคาได้ | ลดราคาโดยไม่ได้รับอนุญาต | TC-010 |
| ค้นหาเมนูผ่าน SQL ที่ไม่ปลอดภัย | ข้อมูลนอกเงื่อนไขอาจถูกเปิดเผย | TC-011 |

## Test Cases & Results

ออกแบบ 25 กรณี: Positive 9, Negative 7, Security 7 และ Edge 2 มากกว่าขั้นต่ำในโจทย์ รวมกับคำขอ SETUP/CLEANUP เป็น 34 requests สคริปต์ตรวจสอบ 35 ชุด

| TC-ID | Feature | Scenario | Input | Expected | Actual | Pass/Fail |
|---|---|---|---|---|---|---|
| TC-001 | Health | Positive — ตรวจสถานะระบบ | GET health | 200 และ status=ok | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-002 | Auth | Positive — เข้าสู่ระบบ admin | admin / รหัสบัญชีทดสอบ | 200 และ JWT | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-003 | Auth | Positive — เข้าสู่ระบบ cashier1 | cashier1 / รหัสบัญชีทดสอบ | 200 และ JWT | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-004 | Auth | Positive — เข้าสู่ระบบ waiter1 | waiter1 / รหัสบัญชีทดสอบ | 200 และ JWT | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-005 | Auth | Negative — รหัสผ่านผิด | admin / wrong | 401 | HTTP 401; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-006 | Auth | Negative — ไม่ส่งข้อมูลล็อกอิน | {} | 400 | HTTP 400; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-007 | Menu | Security — อ่านเมนูโดยไม่มีโทเคน | ไม่ส่ง Authorization | 401 | HTTP 401; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-008 | Auth | Security — ใช้ JWT ปลอม | Bearer invalid | 401 | HTTP 401; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-009 | Menu | Positive — อ่านเมนู | โทเคนแอดมิน | 200 และ array | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-010 | Menu | Security — พนักงานแก้ราคาเมนู | price=1 | 403 และราคาไม่เปลี่ยน | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Fail |
| TC-011 | Menu | Security — ค้นหาด้วยข้อความ SQL | search=' ) OR 1=1 -- | 200 array ว่าง โดยค้นหาเป็นข้อความ | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Fail |
| TC-012 | Menu | Security — พนักงานเพิ่มเมนู | ชื่อและราคาเมนู | 403 | HTTP 403; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-013 | Orders | Negative — เปิดออเดอร์ไม่ระบุโต๊ะ | {} | 400 | HTTP 400; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-014 | Orders | Positive — เปิดออเดอร์ใหม่ | table_id จากโต๊ะว่าง | 201 และ id | HTTP 201; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-015 | Orders | Negative — เปิดออเดอร์ซ้ำโต๊ะ | table_id เดิม | 409 | HTTP 201; ดูผลรอบ 20261014T181929Z-72752 | Fail |
| TC-016 | Orders | Edge — ยืนยันออเดอร์ว่าง | ออเดอร์ไม่มีสินค้า | 400 | HTTP 400; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-017 | Orders | Positive — เพิ่มสินค้า 2 ชิ้น | ราคา 80 จำนวน 2 | 201 และยอด 160 | HTTP 201; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-018 | Orders | Positive — ยืนยันออเดอร์ | ออเดอร์มีสินค้า | 200 confirmed | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-019 | Payment | Edge — จ่ายเงินเกินยอด | ยอด160 จ่าย200 | 201 เงินทอน40 | HTTP 201; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-020 | Payment | Negative — จ่ายซ้ำออเดอร์ที่ชำระแล้ว | ออเดอร์ paid | 400 | HTTP 400; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-021 | Payment | Negative — จ่ายเงินไม่ครบยอด | ยอด160 จ่าย100 | 400 และยังไม่ paid | HTTP 201; ดูผลรอบ 20261014T181929Z-72752 | Fail |
| TC-022 | Orders | Negative — ตรวจสถานะหลังจ่ายไม่ครบ | underpaid_order_id | 200 status=confirmed และไม่มี payment | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Fail |
| TC-023 | Report | Positive — อ่านรายงานยอดขาย | โทเคน cashier | 200 และ totalRevenue เป็นตัวเลข | HTTP 200; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-024 | Report | Security — พนักงานอ่านรายงานยอดขาย | โทเคน waiter | 403 | HTTP 403; ดูผลรอบ 20261014T181929Z-72752 | Pass |
| TC-025 | Payment | Security — ชำระเงินโดยไม่มีโทเคน | ไม่ส่ง Authorization | 401 | HTTP 401; ดูผลรอบ 20261014T181929Z-72752 | Pass |

ไฟล์: [RMS-68030263-TestSuite.json](tests/postman/RMS-68030263-TestSuite.json) และ [env.json](tests/postman/env.json)

ตัวแปร base_url, token, admin_token, cashier_token และ waiter_token ใช้ environment scope เดียวกัน เพื่อไม่ให้ค่าโทเคนเก่าใน environment ทับค่าที่บันทึกจาก login

การปรับจากชุดเดิม: ผมแยกออเดอร์จ่ายไม่ครบจากออเดอร์ที่ชำระแล้ว ใช้ ID จริงจากการสร้างข้อมูล ตรวจเงินทอนเป็น 40 บาทแบบเจาะจง และคืนราคาเมนูก่อนทดสอบการชำระเงิน ส่วน SQL search ใช้ payload ที่ปิดวงเล็บให้ครบและคาดหวังให้ค้นหาเป็นข้อความธรรมดา

## Test Reports

ผมรันบน Docker Staging กับ PostgreSQL16 ในรอบ `20261014T181929Z-72752` Newmanส่ง34คำขอ รวมsetup/cleanup และทดสอบครบ25กรณี

| ตัวชี้วัด | ผลจริง |
|---|---|
| กรณีผ่าน | 20/25 (80%) |
| กรณีไม่ผ่าน | 5 ได้แก่ TC-010,011,015,021,022 |
| Blocked/Not Run | 0 |
| Assertions ผ่าน | 40/46 (86.96%) |
| Unit/API เดิม | 19/20; unit helper ไม่ใช่หลักฐาน payment route |
| Docker | db/backend/frontend Healthy |
| Health | HTTP200 status=ok |

หลักฐานฉบับเผยแพร่ตัดโทเคนและคำขอloginออก: [measured-results.json](tests/reports/20261014T181929Z-72752/measured-results.json), [measured-results.html](tests/reports/20261014T181929Z-72752/measured-results.html) รายงานJSON/HTMLฉบับเต็มยังเก็บไว้ในเครื่องเพื่อใช้อ่านรายละเอียด

## Security Scan Report

ผมใช้ npm audit --audit-level=moderate ทั้งสองส่วน และ npm audit fix จากนั้นอัปเกรด dependency ที่ต้องข้ามเวอร์ชันหลัก พร้อมทดสอบbuild/Docker/Newmanซ้ำ ผลล่าสุดรอบ20261014T181929Z-72752 ไม่พบช่องโหว่ทั้งสองส่วน

| ส่วน/รอบ | Critical | High | Moderate | Low | รวม |
|---|---|---|---|---|---|
| Backend ก่อนแก้ |1|5|4|2|12|
| Frontend ก่อนแก้ |0|12|6|1|19|
| Backend หลังแก้ |0|0|0|0|0|
| Frontend หลังแก้ |0|0|0|0|0|

จำนวนนี้นับpackage entriesในnpm audit ไม่ใช่จำนวนCVEที่ไม่ซ้ำ ผล0ยืนยันเฉพาะdependencyชุดที่ตรวจ ไม่ได้หมายความว่าบั๊กในซอร์สหายไป

### Dependency ระดับ High/Critical ก่อนแก้

| ส่วน | Package | ระดับ | หมายเลขอ้างอิงจาก audit | เวอร์ชันหลังแก้ |
|---|---|---|---|---|
| backend | form-data | high | GHSA-hmw2-7cc7-3qxx | 4.0.6 |
| backend | nanoid | high | GHSA-28wg-ghj8-5hjv; GHSA-2v37-7h3g-55p8 | 3.3.20 |
| backend | postcss | high | GHSA-fxqj-rqcc-2cmp; GHSA-r28c-9q8g-f849 | 8.5.30 |
| backend | proxy-addr | critical | GHSA-jqcg-44mw-7w3h | 2.0.8 |
| backend | source-map-js | high | GHSA-68fv-2mgg-jv7q | 1.2.2 |
| backend | vite | high | GHSA-v6wh-96g9-6wx3; GHSA-fx2h-pf6j-xcff | 8.3.4 |
| frontend | axios | high | GHSA-3w6x-2g7m-8v23; GHSA-q8qp-cvcw-x6jj; GHSA-hfxv-24rg-xrqf; GHSA-777c-7fjr-54vf; GHSA-p92q-9vqr-4j8v; GHSA-j5f8-grm9-p9fc; GHSA-3g43-6gmg-66jw; GHSA-35jp-ww65-95wh; GHSA-898c-q2cr-xwhg; GHSA-pjwm-pj3p-43mv; GHSA-mmx7-hfxf-jppx; GHSA-pmv8-rq9r-6j72; GHSA-mwf2-3pr3-8698; GHSA-7q8q-rj6j-mhjq; GHSA-jqh4-m9w3-8hp9; GHSA-f4gw-2p7v-4548; GHSA-42h9-826w-cgv3; GHSA-hcpx-6fm6-wx23; GHSA-vh66-26gq-q6x8; GHSA-9fr6-4gfg-395g; GHSA-mghh-pgcx-3jjj; GHSA-x97p-jq2g-jp4f; GHSA-3pq3-5fj3-cg6v; GHSA-542g-h47m-68v8; GHSA-j8rh-479h-cp32; GHSA-4hqw-qxg8-jxx2; GHSA-44g4-m2mj-wpvx | 1.20.0 |
| frontend | braces | high | GHSA-vfj7-8cjw-p6xm | ถอดออกจาก dependency tree |
| frontend | browserslist | high | GHSA-c83g-rgw3-j3cx; GHSA-73wf-gq98-2v4g | 4.29.3 |
| frontend | chokidar | high | ผ่าน dependency: braces | ถอดออกจาก dependency tree |
| frontend | fast-glob | high | ผ่าน dependency: micromatch | ถอดออกจาก dependency tree |
| frontend | form-data | high | GHSA-hmw2-7cc7-3qxx | 4.0.6 |
| frontend | micromatch | high | ผ่าน dependency: braces | ถอดออกจาก dependency tree |
| frontend | nanoid | high | GHSA-28wg-ghj8-5hjv; GHSA-2v37-7h3g-55p8; GHSA-xwg4-73v4-xw9w | 3.3.20 |
| frontend | postcss | high | GHSA-6g55-p6wh-862q; GHSA-fxqj-rqcc-2cmp; GHSA-r28c-9q8g-f849 | 8.5.30 |
| frontend | source-map-js | high | GHSA-68fv-2mgg-jv7q | 1.2.2 |
| frontend | tailwindcss | high | ผ่าน dependency: chokidar, fast-glob, micromatch | 4.3.3 |
| frontend | vite | high | GHSA-4w7w-66w2-5vf9; GHSA-v6wh-96g9-6wx3; GHSA-fx2h-pf6j-xcff | 8.3.4 |

ผลauditที่อ่านไม่ได้ให้CVEทุกadvisory จึงระบุGHSAตามข้อมูลจริง ไม่สมมติCVE เวอร์ชันในตารางเป็นเวอร์ชันที่ติดตั้งในlockfileซึ่งauditรอบล่าสุดไม่พบช่องโหว่ ไม่ใช่คำรับรองว่าไม่มีช่องโหว่ในอนาคต

หลักฐาน: `tests/reports/20261014T181929Z-72752/backend-audit-after.log` และ `frontend-audit-after.log` ผลbuildหลังอัปเกรดสำเร็จตามTerminal และDockerยังHealthy; UIหลังอัปเกรดยังต้องตรวจด้วยหน้าเว็บ

## Bug Reports

> Newman รอบ 20261014T181929Z-72752 ยืนยัน HTTP/ฐานข้อมูลของบั๊กทั้ง 4 รายการแล้ว: BUG-001 จาก TC-021/022, BUG-002 จาก TC-015, BUG-003/004 จาก TC-010/011 รายละเอียดจากการอ่านโค้ดด้านล่างเก็บไว้เป็นที่มา ภาพหน้าจอยังต้องเพิ่ม

### BUG-001 รับเงินไม่ครบแต่บันทึกชำระสำเร็จ

**Severity:** Critical  
**Priority:** P1  
**Feature:** Payment  
**สถานะ:** ยืนยันจาก Newman บน Docker Staging แล้ว

**Steps to Reproduce**
1. เปิดออเดอร์ใหม่ เพิ่มเมนูราคา 80 จำนวน 2 และยืนยัน ยอด 160 บาท
2. ล็อกอิน cashier1 แล้ว POST /api/payments ด้วย orderId ที่เพิ่งได้ amountPaid=100 และ method=cash
3. อ่าน GET /api/orders/:id เพื่อดูสถานะและ payment

**Expected Result:** ตอบ 400 ไม่สร้าง payment สถานะยัง confirmed และไม่คืนโต๊ะเป็น available

**Actual Result:** TC-021 ตอบHTTP201 บันทึกเงินรับ100จากยอด160 เงินทอน-60; TC-022 แสดงสถานะpaidและมีpayment แทนconfirmed/ไม่มีpayment

**Evidence:** [payments.ts](backend/src/routes/payments.ts), TC-021 และ TC-022; ดูmeasured-results.json; รอภาพหน้าจอ

**Business Impact:** ร้านอาจรับเงินไม่ครบแต่ระบบบันทึกรายได้เต็มยอด ทำให้ปิดยอดเงินสดไม่ตรง

**ข้อเสนอ:** ตรวจจำนวนเงินว่าเป็นตัวเลขจำกัดช่วงและไม่น้อยกว่ายอดบิลก่อนเขียนข้อมูล แล้วทดสอบขอบเขตเงินทอนและสถานะออเดอร์

### BUG-002 เปิดออเดอร์ซ้ำบนโต๊ะเดียว

**Severity:** High  
**Priority:** P1  
**Feature:** Order  
**สถานะ:** ยืนยันจาก Newman บน Docker Staging แล้ว

**Steps to Reproduce**
1. เลือกโต๊ะว่างและ POST /api/orders
2. POST ซ้ำด้วย tableId เดิมโดยยังไม่ชำระหรือยกเลิกออเดอร์แรก
3. ตรวจรายการออเดอร์ของโต๊ะ

**Expected Result:** ครั้งที่สองตอบ 409 และมีเพียงออเดอร์ active เดียว

**Actual Result:** TC-015 ตอบHTTP201 และสร้างออเดอร์ที่สองบนโต๊ะเดิม แทนHTTP409

**Evidence:** [orders.ts](backend/src/routes/orders.ts), TC-015; ดูmeasured-results.json; รอภาพหน้าจอ

**Business Impact:** พนักงานอาจส่งอาหารหรือเรียกเก็บเงินซ้ำ และการปิดบิลหนึ่งอาจแสดงโต๊ะว่างทั้งที่อีกบิลยังค้าง

**ข้อเสนอ:** ตรวจและล็อกสิทธิ์การเปิดโต๊ะภายใน transaction ให้รองรับคำขอพร้อมกัน ไม่ใช้เพียง findFirst นอก transaction

### BUG-003 พนักงานแก้ราคาเมนูได้

**Severity:** High  
**Priority:** P1  
**Feature:** Menu และสิทธิ์ผู้ใช้  
**สถานะ:** ยืนยันจาก Newman บน Docker Staging แล้ว

**Steps to Reproduce**
1. แอดมินสร้างเมนูทดสอบราคา 80 บาท
2. ล็อกอิน waiter1
3. PUT /api/menu/:id ด้วย price=1

**Expected Result:** 403 และราคาเดิมไม่เปลี่ยน

**Actual Result จากโค้ด:** route PUT ใช้ authenticate แต่ไม่มี requireRole('admin') ก่อน prisma.menuItem.update จึงไม่มีการตรวจบทบาทตรงเส้นทางนี้

**Evidence:** [menu.ts](backend/src/routes/menu.ts), TC-010; ดูmeasured-results.json; รอภาพหน้าจอ

**Business Impact:** พนักงานที่ไม่มีสิทธิ์อาจเปลี่ยนราคา ทำให้ยอดขายและเงินรับผิดพลาด

**ข้อเสนอ:** เพิ่มการตรวจบทบาทที่ backend และซ่อนปุ่มแก้ไขใน frontend ตามสิทธิ์ โดยยังต้องทดสอบ API โดยตรง

### BUG-004 ค้นหาเมนูด้วย SQL ที่ต่อข้อความจากผู้ใช้

**Severity:** High  
**Priority:** P1  
**Feature:** Menu search  
**สถานะ:** ยืนยันจาก Newman บน Docker Staging แล้ว

**Steps to Reproduce**
1. ล็อกอินในระบบทดสอบ
2. ส่ง GET /api/menu โดย search เป็น `' ) OR 1=1 --`
3. ตรวจว่า API ค้นหาข้อความนั้นจริงหรือส่งข้อมูลนอกเงื่อนไข

**Expected Result:** ค้นหาเป็นข้อความธรรมดา ได้ array ว่างสำหรับ fixture นี้ และไม่เปิดเผยข้อมูลนอกเงื่อนไข

**Actual Result:** TC-011 ตอบHTTP200พร้อมรายการเมนู แทนarrayว่างเมื่อค้นหาข้อความpayloadเป็นliteral

**Evidence:** [menu.ts](backend/src/routes/menu.ts), TC-011; ดูmeasured-results.json; รอภาพหน้าจอ

**Business Impact:** ผู้ใช้ที่ล็อกอินอาจอ่านรายการที่ระบบไม่ควรแสดง กระทบความน่าเชื่อถือของข้อมูล

**ข้อเสนอ:** ใช้ Prisma filter หรือ parameterized query และตรวจซ้ำด้วย payload เดิม

### ข้อสังเกตเพิ่มเติม

reports.ts ใช้ gt สำหรับ startDate ทำให้ไม่รวมรายการที่ตรงขอบเวลาเริ่มต้นพอดี ต้องทดสอบด้วย fixture ที่กำหนดเวลาแน่นอนและระบุ timezone ให้ชัด ส่วนชุด unit เดิมคัดลอก helper คำนวณเงินไว้ใน test การแก้ route อย่างเดียวจึงยังไม่ทำให้ test นั้นสะท้อนพฤติกรรม route จริง ควรปรับให้เรียก production logic หรือ API ในรอบแก้บั๊ก

## Deployment Guide

### Prerequisites

Node.js 22+, Git, Docker Desktop/Compose, บัญชี GitHub ของผม, Neon, Render และ Vercel รวมถึงอินเทอร์เน็ตสำหรับติดตั้ง dependencies

ไม่เก็บ DATABASE_URL, JWT_SECRET, deploy hook หรือโทเคนจริงใน Git ใช้ environment ของบริการและ GitHub Secrets

### Local Setup (Docker Compose + Manual)

**เตรียมรีโพสิทอรี่ที่รักษาประวัติต้นฉบับ**
```bash
bash scripts/prepare-submission.sh /absolute/path/RMS-68030263-submission
cd /absolute/path/RMS-68030263-submission
# สร้าง repository ของตนเองผ่าน GitHub ก่อน
git remote add origin https://github.com/YOUR_ACCOUNT/RMS-68030263.git
git add .
git commit -m "Add test plan personalized suite and deployment configuration"
git push -u origin main
```

ต้องแทน YOUR_ACCOUNT และ path จริงก่อนใช้ ห้าม push ไปรีโพสิทอรี่ของอาจารย์

**Manual backend**
```bash
cd backend
cp .env.example .env
# แก้ DATABASE_URL, JWT_SECRET, PORT=3001 และ CORS_ORIGIN=http://localhost:5173
npm ci
npx prisma generate
npx prisma db push
npm run db:seed
npm run dev
```

**Manual frontend อีก terminal**
```bash
cd frontend
cp .env.example .env
# กำหนด VITE_API_URL=http://localhost:3001/api
npm ci
npm run dev -- --host 127.0.0.1
```

**Docker staging**
```bash
cp .env.example .env
# สุ่มค่า POSTGRES_PASSWORD และ JWT_SECRET คนละค่า แนะนำ hex เพื่อไม่ต้อง escape URL
docker compose up --build -d
docker compose ps
curl -f http://localhost:3001/api/health
```

เปิด http://localhost และล็อกอิน ตรวจ container ให้เป็น running/healthy ทุกตัว .env ต้องเปลี่ยนจาก placeholder ก่อนรันจริง ห้ามใช้ docker compose down -v กับฐานข้อมูลที่ต้องเก็บ

### On-Premises Setup

ยังไม่สำเร็จในรอบนี้ ติดตั้งแพ็กเกจไม่ได้และยังไม่มีภาพ login/health

การติดตั้ง Self-Hosted Runner ตามโจทย์: เข้า repository ของผม → Settings → Actions → Runners → New self-hosted runner เลือก OS/architecture ของเครื่อง ทำตามคำสั่งที่ GitHub สร้างให้และใช้ registration token เฉพาะรอบนั้น ติดตั้ง runner เป็น service ตามหน้าจอ และตรวจสถานะ Online ก่อนรันงาน ห้ามบันทึก registration token ในรายงาน

CI ปัจจุบันใช้ GitHub-hosted runner สำหรับการทดสอบ ไม่ใช่หลักฐานว่าติดตั้ง self-hosted runner แล้ว ส่วน on-premises ต้องติดตั้งและเก็บหลักฐานเพิ่มเติม

**หมายเหตุพอร์ต:** โจทย์ระบุ backend 3001 แต่ตัวอย่างภาพหลักฐานเขียน 3000 ผมยึด 3001 ตามซอร์สและส่วนติดตั้ง หากต้องการภาพที่ 3000 ให้ตั้ง PORT=3000 และแก้ VITE_API_URL ให้ตรงกัน ไม่อ้างว่าทั้งสองพอร์ตทำงานโดยไม่ได้รัน

หลักฐานที่ยังต้องเพิ่ม: ภาพ health พร้อม address bar และภาพหน้า frontend หลัง login สำเร็จ

### Staging Environment

docker-compose.yml เพิ่ม PostgreSQL 16, environment ครบ, backend port 3001, frontend port 80, healthcheck และ depends_on แบบ service_healthy แล้ว VITE_API_URL ถูกส่งเป็น build argument เพราะ Vite ฝังค่านี้ตอน build

ปรับ backend Dockerfile ให้ generate Prisma ก่อน build และ compile seed ระหว่าง build เพื่อลดการดาวน์โหลดเครื่องมือเพิ่มตอน start

ผลจริง: compose config ผ่าน แต่ยังไม่มี docker compose up สำเร็จและภาพ docker compose ps ดังนั้น staging smoke test ยังเป็น Not Run

### Neon.tech Database Setup

1. สร้าง Project ในบัญชีผม เลือก PostgreSQL 16 ตามข้อสอบ
2. คัดลอก connection string ที่มี sslmode=require ไปตั้ง DATABASE_URL โดยไม่ใส่ในรายงานหรือ Git
3. ใช้ฐานข้อมูล/branch สำหรับทดสอบแยกจาก production
4. รัน Prisma schema push และ seed เฉพาะฐานข้อมูลที่สร้างสำหรับงานนี้ แล้วตรวจข้อมูลเริ่มต้น

### Render + Vercel Deployment Steps

**Render backend**
- เชื่อม GitHub repository ของผม Root Directory = backend
- Build: npm ci && npx prisma generate && npm run build
- Start ตามข้อสอบ: npx prisma db push && npx tsx prisma/seed.ts && npm start
- ตั้ง DATABASE_URL, JWT_SECRET, CORS_ORIGIN และ NODE_ENV=production
- เก็บ dependencies สำหรับ prisma/tsx ตาม start command ไม่ตั้ง NPM_CONFIG_PRODUCTION=true ซึ่งจะตัด devDependencies ที่จำเป็น
- ตรวจ /api/health และบันทึก URL จริง

**Vercel frontend**
- Root Directory = frontend, Framework = Vite
- Build = npm run build, Output Directory = dist
- ตั้ง VITE_API_URL=https://BACKEND_HOST/api ก่อน build
- เมื่อได้ frontend URL แล้วนำไปตั้ง CORS_ORIGIN ของ Render และ deploy backend ใหม่
- มี vercel.json สำหรับ SPA deep links

**CI-controlled deployment**
- ตั้ง GitHub environment ชื่อ production และ secrets RENDER_DEPLOY_HOOK / VERCEL_DEPLOY_HOOK
- หากใช้ workflow เป็นตัวควบคุม deploy ต้องปิด automatic Git deploy ของทั้งสองบริการเพื่อไม่ให้ข้าม test gate
- HTTP สำเร็จจาก deploy hook หมายถึงรับคำขอ deploy ไม่ใช่ยืนยันว่าเว็บพร้อม ต้องตรวจสถานะบริการและ smoke test หลังจบอีกครั้ง
- ขณะยังมีบั๊ก Critical/High ให้ deploy เฉพาะงานสาธิตที่ใช้ข้อมูลทดสอบ หลังแก้บั๊กและผ่าน gate แล้วจึงพิจารณาใช้งานจริง

### Environment Variables Table

| ตัวแปร | ใช้ที่ไหน | ค่า/หลักการ |
|---|---|---|
| DATABASE_URL | Backend | PostgreSQL connection string; Neon ต้องมี SSL |
| JWT_SECRET | Backend | ค่าสุ่มยาวอย่างน้อย 32 ตัว ไม่ใช้ค่า fallback |
| CORS_ORIGIN | Backend | frontend origin เช่น http://localhost:5173 ไม่มี /api |
| NODE_ENV | Backend | development / test / production ตามบริบท |
| PORT | Backend | 3001 สำหรับ local; cloud ใช้พอร์ตจาก provider |
| VITE_API_URL | Frontend build | http://localhost:3001/api หรือ cloud backend ลงท้าย /api |
| POSTGRES_PASSWORD | Docker database | ค่าสุ่มสำหรับฐานข้อมูล staging |
| RENDER_DEPLOY_HOOK | GitHub Secrets | URL ลับของ Render |
| VERCEL_DEPLOY_HOOK | GitHub Secrets | URL ลับของ Vercel |

### Smoke Test Results

| Feature | Local | Staging | Production | หลักฐานที่ต้องเพิ่ม |
|---|---|---|---|---|
| Health status ok | Not Run | Not Run | Not Run | URL และ JSON |
| Login admin | Not Run | Not Run | Not Run | หน้าเว็บหลัง login |
| เปิดโต๊ะ เพิ่มสินค้า Confirm | Not Run | Not Run | Not Run | ออเดอร์และยอดรวม |
| Payment และเงินทอน | Not Run | Not Run | Not Run | ยอดบิล เงินรับ เงินทอน |

## CI/CD Pipeline + Newman Pass Rate

Workflow อยู่ที่ [.github/workflows/cicd.yml](.github/workflows/cicd.yml) ทำงานเมื่อ push main, pull request หรือสั่งเอง ติดตั้ง Node.js 22, PostgreSQL 16, build ทั้งสองส่วน, รัน unit/API, audit และ Newman พร้อมเก็บรายงาน

ใช้ continue-on-error เฉพาะเพื่อให้เก็บผลหลายส่วนได้ครบ แต่มี final gate ตรวจ outcome ทุกส่วน หากมีข้อใดไม่สำเร็จ job จะ fail และ deploy ไม่ทำงาน ไม่ได้กลบผลทดสอบที่ล้มเหลว

ยังไม่มี GitHub Actions run URL ของงานรอบนี้ ส่วน NewmanบนStagingผ่าน20/25 (80%) และassertions40/46 (86.96%) เป็นคนละตัวชี้วัด ผลทดสอบบั๊กต้นฉบับยังFail จึงทำให้test gateไม่ผ่านตามจริง

## รายการที่ต้องทำก่อนส่ง MS Teams

- [x] Test Plan และTest Cases25กรณี
- [x] Newmanครบ25กรณี พร้อมผลจริงและBug Reports4รายการ
- [x] npm auditก่อน/หลังแก้; ล่าสุด0ทั้งBackend/Frontend
- [x] Docker Stagingและhealthผ่าน
- [ ] commit/pushงานรอบนี้จากTerminal ด้วยscripts/publish-submission.sh
- [ ] ภาพหน้าจอบั๊กอย่างน้อย2รายการ และภาพDocker compose ps
- [ ] On-Premisesที่พอร์ต5173 พร้อมlogin และSelf-Hosted Runner
- [ ] เปลี่ยนรหัสฐานข้อมูลที่เคยเปิดเผยในรายงานสาธารณะเดิม และอัปเดตRender
- [ ] ยืนยันdeployซอร์สล่าสุดบนNeon/Render/Vercel และProduction Smoke4รายการ
- [ ] ส่ง3URLผ่านMS Teams

ผมยังไม่ส่งงานจนหลักฐานที่เหลือครบ ข้อสอบกำหนดให้รายงานบั๊ก จึงเก็บผลFailตามจริง ไม่ปรับexpectedเพื่อให้CIผ่าน

GitHubปฏิเสธการสร้างสาขาผ่านช่องทางเชื่อมต่อด้วยHTTP403 Resource not accessible by integration เตรียมสคริปต์ให้โคลนรีโพสิทอรี่ของผม สร้างสาขาแยก คัดลอกซอร์สและหลักฐานที่ตัดโทเคนออก แล้วcommit/pushจากTerminalโดยรักษาmainเดิม
