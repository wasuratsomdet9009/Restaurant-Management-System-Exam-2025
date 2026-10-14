# RMS 68030263

งานของนายวสุรัชต์ สมเด็จ รหัส 68030263

อ่าน Exam-Result.md เป็นไฟล์หลัก มีแผนทดสอบ 25 กรณี รายงานข้อบกพร่องจากโค้ด 4 รายการ และวิธีติดตั้ง

**สถานะล่าสุด:** build/Docker/health ผ่าน auditไม่พบช่องโหว่ Newmanผ่าน20/25 (80%) Unit/APIเดิมผ่าน19/20 ยังขาดภาพหลักฐาน Self-Hosted Runner และผลProductionปัจจุบัน

1. ใช้ scripts/prepare-submission.sh โคลนไปโฟลเดอร์ใหม่เพื่อรักษาประวัติ Git ของอาจารย์
2. ติดตั้ง dependencies และตั้งฐานข้อมูลทดสอบ
3. รันระบบและ bash scripts/run-suite.sh แล้วเติมผลจริงใน Exam-Result.md
4. ตรวจ npm audit และแก้ช่องโหว่ตามผลจริง
5. ตั้ง Self-Hosted Runner, Docker staging และ Neon/Render/Vercel
6. เก็บภาพและ URL จริง ก่อนส่งผ่าน MS Teams

โค้ดบั๊กต้นฉบับยังคงอยู่เพื่อใช้ตรวจพบและรายงาน ชุดทดสอบจึงอาจ Fail ตามบั๊ก ไม่ควรแก้ expected ให้ยอมรับพฤติกรรมผิด

ห้ามใช้ข้อมูลร้านจริงกับชุดทดสอบนี้ เนื่องจากมีการสร้างเมนู ออเดอร์ และชำระเงินทดสอบ

อัปเดต 15 ต.ค. 2569: รัน logic tests แบบ mock แล้ว 6 กรณี ผ่าน4 ไม่ผ่าน2 ดู tests/reports/route-logic.json; หลังเปิด Docker และเครือข่ายให้รัน bash scripts/finish-local.sh เพื่อเก็บผลชุดเต็ม

ผลล่าสุด: Docker Staging Healthy; Newman ผ่าน20/25 (80%); unit/API เดิมผ่าน19/20; audit ยังพบช่องโหว่ ดูผลปัจจุบันใน Exam-Result.md

รันแก้ dependency แบบไม่ใช้ --force และเก็บหลักฐานก่อน/หลัง:
```bash
bash scripts/finish-local.sh --fix-dependencies
```
บั๊กต้นฉบับยังทำให้ Newman Fail ได้ตามจริง อย่าเปลี่ยน expected เพื่อให้ผ่าน
