# PR0: Đề xuất kiến trúc Weekly Commitment và Missed-session Recovery

Base: `feature/steady-brand-identity` tại `5fd636334e86c71582b6ae62a858d1d183eb62db`.

App hiện tính active days/streak từ nhật ký local và nhắc hai giờ mỗi ngày, chưa có
weekly target snapshot, planned sessions, recovery hoặc product analytics. PR0 đưa
ra hợp đồng để review trước khi triển khai: PRD/screen disposition, flows, ADR so sánh
SQLite và Supabase, schema/state machine, event/KPI definitions, query drafts và test matrix.

Đề xuất Android beta local-first; planned session tách actual activity, giữ mẫu số
đầu tuần, một credit/root kể cả retry/short alternative. Rest không tạo completion.
Mọi đề xuất D01–D13 cần chủ sản phẩm duyệt; **không tiếp tục PR1 trước architecture gate**.

## Phạm vi và data impact

Chỉ Markdown. Không thay code/UI/dependencies, không migration thực thi, không ghi
production hay merge. Không mất/chuyển logs v2, không merge guest/account. Không thêm
social/chat/leaderboard/LLM hay mở rộng meal planning. Không screenshot mới vì UI không đổi.
Docs scope/Android build được gắn đúng current-versus-historical context.

## Verification

Xem [kết quả thực thi](verification.md) và [acceptance matrix](acceptance-and-delivery.md).
Base HEAD trùng audit; đọc lại source, không dùng branch main. Kết quả chạy hiện tại:

- `flutter analyze --no-pub`: PASS, No issues found.
- `flutter test --no-pub --reporter expanded`: 172 passed, 1 skipped (browser-only).
- `flutter build apk --debug --no-pub`: PASS; không tái hiện lỗi loopback audit cũ.
- Relative Markdown links resolve; whitespace diff được kiểm tra.

Staging/Android devices/usability/research chưa chạy; không claim exit criteria roadmap.

## Rollback và giới hạn

Revert docs-only commit; không tác động dữ liệu/runtime. Kiến trúc đề xuất chưa có
multi-device sync/backup, web/desktop engine parity hay empirical validation thresholds.
Ngưỡng KPI là giả định; 50–100 người/28 ngày và phỏng vấn cần thực hiện bởi nhóm sản phẩm.

## Review checklist

- [ ] D01–D13 trong [architecture gate](README.md) được trả lời rõ.
- [ ] ADR/schema/state transitions nhất quán với acceptance matrix.
- [ ] Cohort/censoring/consent và giới hạn local-only được chấp thuận.
- [ ] Tách phần công việc nghiên cứu khỏi engineering completion.
- [ ] Sau review vẫn dừng PR0; không tự merge/deploy/triển khai engine.
