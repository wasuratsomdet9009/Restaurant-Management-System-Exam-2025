# Newman measured results

Assertions: 40/46 passed (86.96%).

Executed cases: 25; passed 20; failed 5; blocked 0. Case pass rate including blocked: 80.00%.

These are executed cases only; compare with the planned suite to detect unexecuted requests.

| Case | HTTP | Result |
|---|---|---|
| TC-001 ตรวจสถานะระบบ | 200 | Pass |
| TC-002 เข้าสู่ระบบ admin | 200 | Pass |
| TC-003 เข้าสู่ระบบ cashier1 | 200 | Pass |
| TC-004 เข้าสู่ระบบ waiter1 | 200 | Pass |
| TC-005 รหัสผ่านผิด | 401 | Pass |
| TC-006 ไม่ส่งข้อมูลล็อกอิน | 400 | Pass |
| TC-007 อ่านเมนูโดยไม่มีโทเคน | 401 | Pass |
| TC-008 ใช้ JWT ปลอม | 401 | Pass |
| TC-009 อ่านเมนู | 200 | Pass |
| TC-010 พนักงานแก้ราคาเมนู | 200 | Fail |
| TC-011 ค้นหาด้วยข้อความ SQL | 200 | Fail |
| TC-012 พนักงานเพิ่มเมนู | 403 | Pass |
| TC-013 เปิดออเดอร์ไม่ระบุโต๊ะ | 400 | Pass |
| TC-014 เปิดออเดอร์ใหม่ | 201 | Pass |
| TC-015 เปิดออเดอร์ซ้ำโต๊ะ | 201 | Fail |
| TC-016 ยืนยันออเดอร์ว่าง | 400 | Pass |
| TC-017 เพิ่มสินค้า 2 ชิ้น | 201 | Pass |
| TC-018 ยืนยันออเดอร์ | 200 | Pass |
| TC-019 จ่ายเงินเกินยอด | 201 | Pass |
| TC-020 จ่ายซ้ำออเดอร์ที่ชำระแล้ว | 400 | Pass |
| TC-021 จ่ายเงินไม่ครบยอด | 201 | Fail |
| TC-022 ตรวจสถานะหลังจ่ายไม่ครบ | 200 | Fail |
| TC-023 อ่านรายงานยอดขาย | 200 | Pass |
| TC-024 พนักงานอ่านรายงานยอดขาย | 403 | Pass |
| TC-025 ชำระเงินโดยไม่มีโทเคน | 401 | Pass |
