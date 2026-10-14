# Restaurant Management System (RMS) — 68030263

**ผู้จัดทำ:** นายวสุรัชต์ สมเด็จ  
**รหัสนักศึกษา:** 68030263  
**รายวิชา:** การออกแบบและพัฒนาซอฟต์แวร์ 1  
**อัปเดตล่าสุด:** 15 ตุลาคม 2569

รายงานฉบับเต็ม (ผลทดสอบ บั๊ก และหลักฐานทุกส่วน) อยู่ที่ [Exam-Result.md](Exam-Result.md) ไฟล์นี้สรุปสถานะและวิธีรันเท่านั้น

## ลิงก์งาน

| รายการ | ลิงก์ / สถานะ |
|---|---|
| GitHub Repository (Public) | https://github.com/wasuratsomdet9009/Restaurant-Management-System-Exam-2025 |
| Branch ของงาน | `submission/68030263-20261015` (commit ล่าสุดตามประวัติ Git) — default branch ยังเป็น `main` เดิม |
| Production Frontend | ยังไม่ได้ deploy รอผู้ใช้ตั้งค่า Vercel |
| Production Backend `/api/health` | ยังไม่ได้ deploy รอผู้ใช้ตั้งค่า Render และ Neon |
| CI run (GitHub Actions) | ดูหัวข้อ CI/CD ด้านล่าง |

## สถานะที่ยืนยันแล้ว

- Build Backend/Frontend ผ่าน และ `npm audit` ทั้ง Backend และ Frontend ไม่พบช่องโหว่ (0)
- Docker Compose (Staging): `db`, `backend`, `frontend` สถานะ healthy, `GET /api/health` ตอบ `{"status":"ok"}`
- Newman: ผ่าน 20/25 กรณี (80%), assertions 40/46 (86.96%) — 5 กรณีล้มเหลวเพราะบั๊กต้นฉบับ ตั้งใจเก็บไว้ ไม่ได้แก้ expected
- Unit/API เดิม (Vitest): 1 ไฟล์ผ่าน 1 ไฟล์ล้มเหลว (BUG-001 ใน `payment.test.ts`) — helper ในไฟล์ทดสอบเป็นสำเนาการคำนวณ ไม่ใช่ route จริง
- On-Premises: PostgreSQL 16.15 บนเครื่อง, Backend รันจริง, Frontend ที่ `http://localhost:5173` เข้าสู่ระบบ admin ได้ (ดูหัวข้อ On-Premises)
- GitHub Actions Self-Hosted Runner `rms-68030263-mac` (macOS ARM64) สถานะ online และรัน job `onprem` (ดูหัวข้อ CI/CD)

## ยังไม่เสร็จ

- Neon: ยังไม่ได้เปลี่ยนรหัส role ที่เคยเปิดเผยในรายงานบน `main` เดิม (ผู้ใช้ต้องดำเนินการเอง)
- Render และ Vercel: ยังไม่ได้ deploy จากสาขานี้ จึงยังไม่มี Production smoke test
- Staging ตรวจแล้วบนสำเนาโฟลเดอร์ที่ source เหมือนกัน (ดูหมายเหตุใน Exam-Result.md)

## Tech Stack (เวอร์ชันจาก package-lock.json)

| ส่วน | เทคโนโลยี | เวอร์ชัน |
|---|---|---|
| Frontend | React, Vite, Tailwind CSS, React Router | 18.3.1, 8.3.4, 4.3.3, 7.18.4 |
| Backend | Node.js (ที่ใช้ทดสอบ), Express, TypeScript | 22.17.1, 4.22.3, 5.9.3 |
| Database | PostgreSQL (Docker และ on-prem), Neon (ยังไม่ได้ตั้ง) | 16.15 |
| ORM | Prisma | 5.22.0 |
| Testing | Vitest, Newman | 4.1.11, Newman ตาม CI |

## รันระบบบนเครื่อง (On-Premises)

ตั้งค่า `backend/.env` จาก `backend/.env.example` (ห้าม commit) แล้วรัน

```bash
cd backend
npm ci
npx prisma generate
npx prisma db push
npm run db:seed
npm run dev
```

```bash
cd frontend
npm ci
VITE_API_URL=http://localhost:3001/api npm run dev -- --host 127.0.0.1 --port 5173
```

บัญชีทดสอบ (ข้อมูลทดสอบเท่านั้น): `admin / Admin@123`, `cashier1 / Cashier@123`, `waiter1 / Waiter@123`

## รันด้วย Docker Compose (Staging)

```bash
cp .env.example .env   # ตั้งค่า POSTGRES_PASSWORD และ JWT_SECRET เป็นค่าสุ่มของตนเอง
docker compose up --build -d
docker compose ps
curl -f http://127.0.0.1:3001/api/health
```

เปิด `http://localhost` (frontend พอร์ต 80, backend พอร์ต 3001) ห้ามใช้ `docker compose down -v` กับฐานข้อมูลที่ต้องเก็บ

## Cloud Deployment

- **Neon:** PostgreSQL 16, ใช้ connection string ที่มี `sslmode=require` และตั้งใน Render เท่านั้น
- **Render:** ใช้ [render.yml](render.yml) เป็น Blueprint แบบ Native Node (Root Directory `backend`) — Build: `npm install && npx prisma generate && npm run build` (ใช้ `backend/.npmrc` ที่ตั้ง `include=dev` เพื่อให้ tsc/prisma/tsx ถูกติดตั้งแม้ NODE_ENV=production), Start: `npx prisma db push && npx tsx prisma/seed.ts && npm start`, Health: `/api/health`
- **Vercel:** Root Directory `frontend`, Framework Vite, Output `dist`, ตั้ง `VITE_API_URL=https://<backend-host>/api` ก่อน build; [frontend/vercel.json](frontend/vercel.json) มี SPA rewrite สำหรับ `/login` และการ refresh
- **CORS_ORIGIN** ของ Render ต้องเป็น origin ของ Vercel เท่านั้น (ไม่มี `/api`)

## CI/CD

ไฟล์ [.github/workflows/cicd.yml](.github/workflows/cicd.yml)

- trigger: push ไป `main` และ `submission/68030263-20261015`, pull request เข้า `main`, และ `workflow_dispatch`
- job `test` (ubuntu-latest): Node.js 22, PostgreSQL 16 service, build, Unit/API, `npm audit --audit-level=high` ทั้งสองส่วน, Newman, แล้ว gate ตรวจทุกผลลัพธ์
- job `onprem` (self-hosted, macOS, ARM64): PostgreSQL 16 แบบ container ชั่วคราว, build, db push, seed, เปิด API และตรวจ health กับ admin login — เฉพาะ push เท่านั้น เพราะเป็น repository สาธารณะ
- job `deploy`: เฉพาะ push ไป `main` และต้องผ่าน `test`

ผล CI รอบล่าสุดที่รันบนสาขางาน: https://github.com/wasuratsomdet9009/Restaurant-Management-System-Exam-2025/actions/runs/38628698763 (commit 224bc40)
- `onprem`: **success** บน self-hosted runner `rms-68030263-mac`
- `test`: **failure** ตาม gate เพราะ Unit มี 1 กรณีล้มเหลวและ Newman มี 5 กรณีล้มเหลว จากบั๊กต้นฉบับ (ตั้งใจ ไม่ได้ซ่อน)
- `deploy`: skipped (ทำงานเฉพาะ push ไป main)

## บั๊กที่พบ (รายละเอียดและภาพใน Exam-Result.md)

| ID | ความรุนแรง | ฟีเจอร์ | หลักฐาน |
|---|---|---|---|
| BUG-001 | Critical | Payment รับเงินไม่ครบแต่บันทึกว่าชำระแล้ว (รับ 100 จาก 160 เงินทอน -60) | UI: [ภาพ](tests/reports/20261015-ui-evidence/bug-001-cashier-underpayment-result-staging.jpg), Newman TC-021/022 |
| BUG-002 | High | เปิดออเดอร์ซ้ำบนโต๊ะเดียวกัน ได้ 201 แทน 409 | UI: [ภาพ](tests/reports/20261015-ui-evidence/bug-002-two-open-orders-table1-staging.jpg), [log API](tests/reports/20261015-ui-evidence/bug-002-duplicate-open-order-api.log) |
| BUG-003 | High | พนักงาน (waiter) แก้ราคาเมนูได้ | UI: [ภาพ](tests/reports/20261015-ui-evidence/bug-003-waiter-edits-price-staging.jpg), Newman TC-010 |
| BUG-004 | High | ค้นหาเมนูด้วย SQL ที่ต่อข้อความ ได้รายการแทนอาร์เรย์ว่าง | Newman TC-011 |

## ความปลอดภัยและข้อจำกัด

- ไม่มีโมเดลสต็อกวัตถุดิบใน `schema.prisma` จึงทดสอบการตัดสต็อกไม่ได้
- `backend/src/middleware/auth.ts` มี fallback JWT secret ในโค้ด (ข้อสังเกตจากการอ่านโค้ด ยังไม่ได้ทดสอบเชิงโจมตี)
- ไม่มี connection string, JWT secret, token หรือ registration token ใน Git
