# Acceptance matrix và delivery plan

Tất cả test core mới dưới đây là **planned, chưa chạy**. Test cũ không chứng nhận
Commitment/Recovery. D01–D03 đã được chốt riêng, D04–D13 cần duyệt trước PR1.
Không merge/deploy tự động.

## Acceptance matrix

| ID | Scenario / expected outcome | Verification / PR |
|---|---|---|
| AC01 | Targets 1,7 hợp lệ; 0,8 bị chặn; đa môn round-trip | Unit + DB / PR2 |
| AC02 | Target tuần này 3, edit 5: tuần này vẫn 3, repeat tuần mới 5 | Clock/repository / PR2–3 |
| AC03 | 2 buổi cùng ngày target 3 ⇒ 2/3; 4 buổi ⇒ 100% | Domain / PR2 |
| AC04 | Migrate v1/v2 + reopen giữ mọi field/log/owner, không commitment lịch sử | SQLite fixture/integrity / PR2 |
| AC05 | Guest/A/B không đọc/link chéo; login không merge | DB constraints + widget / PR2–3 |
| AC06 | Lỗi ghi giữa activity và credit/outbox: rollback tất cả, retry thành công một lần | Fault injection transaction / PR1–3 |
| AC07 | Double-tap khác command IDs, retry/restart cùng command, short replacement ⇒ một credit/root | Concurrent DB/reopen / PR3–4 |
| AC08 | Session/commitment CAS conflict refresh; completion thắng reschedule không bị ghi đè | Repository concurrency / PR3–4 |
| AC09 | Monday boundary, first partial, DST spring/fall, travel/zone transition không overlap/credit đôi | Injected clock + timezone fixtures / PR2–3 |
| AC10 | Grace boundary trước/đúng/sau deadline; app mở muộn: một miss/episode và đúng occurred_at | ST03/ST17 domain / PR4 |
| AC11 | Dời/short trong tuần giữ root và target; chọn chưa phải fulfilled | ST04–06 unit + UI / PR4 |
| AC12 | Qua tuần tạo root mới/trace, không credit tuần cũ; không có commitment mới phải xác nhận | ST16 repository/UI / PR4 |
| AC13 | Rest không log/credit; health pause mọi reminders, rollover không tự bật | ST08/ST12 controller/device fake / PR4–5 |
| AC14 | Backdate đúng hạn retract miss; tập sau deadline giữ miss; cutoff journal/KPI rõ ràng | ST13–15 projection fixtures / PR3–4 |
| AC15 | Undo/correction/complete lại chỉ một active credit, audit/revision đầy đủ | ST11–15 repository / PR3–4 |
| AC16 | Threshold 9/10 phút, short 4/5 phút; lựa chọn short sau actual start không hợp lệ | ST05–07 domain / PR4 |
| AC17 | Interval overlap không credit hai lần, log tự do trước commitment không tự link | Transaction/domain / PR3 |
| AC18 | Cancel trước/sau miss không giảm mẫu số; undo sau deadline đúng state | ST09–12 domain / PR3–4 |
| AC19 | Account switch khi delayed read/write/upload/reminder: stale callback không lộ dữ liệu | Controller/fake async / PR1–5 |
| AC20 | Outbox offline/retry/restart/ack loss dedup; view rebuild không phát lại | Integration fake sink / PR1 |
| AC21 | Consent off không queue; revoke purge và drop in-flight old generation; resubscribe không backfill | Sink contract/DB / PR1 |
| AC22 | Allowlist rejects health detail/email/token/free text; owner binding A/B/anon đúng | Unit + staging / PR1 |
| AC23 | Week-4 cohort zero activity vẫn mẫu số; censoring/late consent/correction chính xác | Dashboard fixture SQL / PR1, PR6 |
| AC24 | Action selected ≠ completed; rest không fulfillment; permission denial ≠ annoyance | Projection + widget / PR1, PR4–6 |
| AC25 | Native cancel/replace hoàn thành/nghỉ/logout, stable IDs không collision, stale taps bị bỏ | Adapter tests + Android / PR5 |
| AC26 | Notification permission denied/offline/reboot/timezone/resume và init throws không chặn core | Fault injection + Android / PR5 |
| AC27 | Android APK cài chạy ≥3 cấu hình, không crash nghiêm trọng/mất dữ liệu trong vòng QA | Physical/emulator matrix có version/SHA / PR5 |
| AC28 | First-time commitment + log ≤2 phút, VI/EN chữ lớn, không cần hướng dẫn của tester | Timed usability với người mới / PR3 |
| AC29 | Mọi main transition ST01–ST17 được test, ≥95% critical functional cases pass, không skipped tính pass | Traceability report / PR3–5 |
| AC30 | Review/repeat hai lần không tạo trùng, bỏ tuần không dựng history giả | Repository + UI / PR3 |
| AC31 | Hide navigation vẫn truy cập dữ liệu legacy, không mất logs/food; theme/VI-EN giữ | Widget/regression / PR3 |
| AC32 | Backup/migration fail/compatibility rollback bảo toàn v2 + ghi mới | DB migration/reopen / PR2 |
| AC33 | Local-only beta nói rõ mất journal khi clear data và không sync; Preferences không bật engine | Platform/widget + onboarding review / PR2 |
| AC34 | 50–100 participant, 28d observation, ba bottlenecks, Go/Iterate/Pivot có evidence | Human research / PR6, hiện chưa đo |

AC01–AC33 là critical engineering matrix ban đầu, mỗi row phải tách concrete cases
và freeze denominator trước chạy acceptance. Tỷ lệ ≥95% = passed / toàn bộ cases
critical đã freeze; failed/skipped/blocked đều không pass. 100% cases bảo toàn dữ liệu,
owner isolation, idempotency, rest safety phải pass dù tổng ≥95%. AC28 là usability
thực tế, không thay bằng widget test. PR0 không claim matrix này đã đạt.

## D03 — Phân rã AC09 thành ca nghiệm thu thời gian

Status: planned/not run trên app; chỉ các số giờ của ví dụ đã được tính độc lập bằng
Python zoneinfo. Đây là thiết kế nghiệm thu cho PR2–3, không phải tests đang pass.

| ID | Input / expected outcome |
|---|---|
| D03-T01 | Device Europe/Berlin + locale vi: chain khởi tạo Europe/Berlin, không chọn zone theo ngôn ngữ |
| D03-T02 | Bangkok 09/11/2026 00:00 → 16/11 00:00: 168h; instant end không thuộc kỳ cũ |
| D03-T03 | New York 02/03 → 09/03/2026: 167h; vẫn tuần bình thường, không transition |
| D03-T04 | New York 26/10 → 02/11/2026: 169h; không cộng cứng 168h |
| D03-T05 | Máy đổi Bangkok → Berlin giữa tuần: persisted zone/start/end/session UTC kỳ hiện tại giữ nguyên, candidate có preview |
| D03-T06 | Xác nhận đổi Bangkok → Berlin tại boundary 16/11/2026 00:00 Bangkok: kỳ chuyển tiếp [15/11 17:00Z, 15/11 23:00Z), 6h; preview nói rõ, không tự cộng tuần hay prorate target |
| D03-T07 | Bangkok → Tokyo cùng boundary: [15/11 17:00Z, 22/11 15:00Z), 166h; kỳ sau Monday–Monday Tokyo |
| D03-T08 | Start trùng Monday 00:00 zone mới: end là Monday kế tiếp, không kỳ 0h; alias ID không làm thay đổi instants |
| D03-T09 | Hủy pending hoặc device đổi lần nữa: kỳ hiện tại không đổi; preview stale không được xác nhận vào revision mới |
| D03-T10 | App restart qua effective boundary: reconcile bằng boundary đã lưu, không dùng now; apply idempotent, không tạo commitment tuần vắng khi D04 chưa cho phép |
| D03-T11 | Invalid/unavailable IANA: giữ chain cũ; chuỗi mới giữ draft/retry, không fallback âm thầm; journal vẫn dùng được |
| D03-T12 | DST wall time trùng/không tồn tại, tzdb update, account switch hoặc confirm sau rollover: resolve/preview theo ADR, không sửa lịch cũ hoặc áp preview sang owner/kỳ khác |

## PR dependency và rollback

| PR / roadmap | Dependency và phạm vi | Gate / rollback |
|---|---|---|
| PR0 / W1–2 | PRD, flows, ADR/schema/events/KPI/matrix | D01–D13; docs revert không ảnh hưởng data |
| PR1 / W1–2 foundation | Accepted ADR; CI baseline, consent/outbox/interface/fake sink, dashboard contract | analyze/tests, AC20–24; tắt upload, giữ local data/schema, không phát health data |
| PR2 / W3–5 | PR1; domain/repository/migrations + target/đa môn onboarding | AC01–09/32/33; feature off + compatibility build, không downgrade destructive |
| PR3 / W3–5 | PR2; planner/completion/progress/review/repeat/navigation | AC07–09/14–19/28–31; disable new navigation/write entry, giữ schema/logs |
| PR4 / W6–7 | PR3; missed detection/actions/short/rest/correction UI | ST01–17 và health policy; tắt prompts/actions, giữ outcome/audit và credit |
| PR5 / W8 | PR4; session reminders, Android startup/readiness, share/rules prototype nội bộ | ≥3 Android configs, staging analytics; cancel new notifications, không bật lại legacy FCM tự động |
| PR6 / W9–12 | PR5 + tuyển người/consent/baseline | 50–100 người, 28 ngày, báo cáo mẫu/censoring/3 bottlenecks; dừng experiments bằng assignment flag, giữ consent rights |

Không PR nào tự merge/deploy production. Rollback migration giữ data và cần diễn tập
trên bản sao/staging. Dependency versions không upgrade hàng loạt. CI baseline phản ánh
checks thật, không điều chỉnh rules chỉ để test xanh. Domain/controller mới tách khỏi
SteadyStore nutrition/research; tái dùng clock/repository injection và brand tests.

## Công việc con người và release evidence

- Phase 0: phỏng vấn 10–15 người, ít nhất 8 xác nhận qua hành vi; prototype đi trọn
  journey. PR0 tài liệu không đáp ứng hai tiêu chí này; hiện chưa thực hiện.
- Android QA dự kiến: một cấu hình API <33, một API ≥33 có runtime notification
  permission, một thiết bị/OEM giới hạn background. Ghi model/API/ABI/SHA, install,
  offline, kill/reopen, reboot, permission, timezone; danh sách thiết bị thật cần chọn PR5.
- Staging auth/RLS: account A/B + anon + stale token owner switch; migration thứ tự
  legacy reminders → food → local reminders trong source, không chứng minh deploy.
- Beta: báo cả người không quay lại, withdrawal, missing measurement; các mục Go gate
  đều “chưa đo” tới khi đủ dữ liệu. Không giả interviews/retention hay khẳng định nhân quả.
- Share: ≥20% invited tried cùng phỏng vấn không áp lực; rules: ≥60% suitable, ≥30%
  accepted, không lỗi nghiêm trọng trong safety fixtures. Nếu không đạt thì hoãn,
  không mở backend social/chat/leaderboard hoặc LLM infrastructure.
