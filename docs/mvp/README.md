# PR0 — Hợp đồng MVP và architecture gate

Ngày 05/11/2026 (Asia/Bangkok). **Draft — chưa được duyệt kiến trúc.**

Base: `feature/steady-brand-identity`, SHA `5fd636334e86c71582b6ae62a858d1d183eb62db`.
Branch làm việc: `docs/pr0-mvp-architecture`. PR0 chỉ thay đổi tài liệu; không đổi UI,
domain, dependency, database hay production. Các từ “sẽ/phải” dưới đây là hợp đồng
đề xuất cho PR sau, không mô tả chức năng đã tồn tại.

## Đọc theo thứ tự

1. [PRD delta và user flows](prd-and-flows.md).
2. [ADR-001: lưu trữ và quy tắc domain](adr-001.md).
3. [Schema và state machine dự thảo](schema-and-transitions.md).
4. [Analytics, KPI và query dự thảo](analytics.md).
5. [Acceptance matrix và kế hoạch PR](acceptance-and-delivery.md).
6. [Bằng chứng source và kiểm chứng hiện tại](verification.md).
7. [Mô tả PR](pr-description.md).

Nguồn: `Steady-Codex-PR-Prompt.md`, `Steady-MVP-Technical-Audit-VI.md`,
`Steady-MVP-Verification.md` do người dùng cung cấp; roadmap đầy đủ
“STEADY — MVP Development Roadmap — 12-week execution plan · November 2026 ·
Flutter / Android-first” được người dùng dán trong cuộc trò chuyện ngày 05/11/2026.
Audit và verification đã được đọc từ thư mục dự án ChatGPT; không dùng audit `main`.
HEAD trùng SHA tham chiếu nên không có delta code cần cập nhật so với audit.
Các tỷ lệ ưu tiên 37.5/37.5/12.5/12.5 là trọng tâm sản phẩm, không là tiến độ hay ngân sách.

## Checklist quyết định cần chủ sản phẩm xác nhận

**D02 được người dùng yêu cầu triển khai riêng ngày 05/11/2026.** Xem
[phạm vi triển khai D02](d02-navigation.md). D01 và D03–D13 vẫn **pending**;
không coi phê duyệt D02, việc tạo PR hay test xanh là duyệt toàn bộ kiến trúc.

| ID | Mặc định đề xuất | Tradeoff / phương án khác |
|---|---|---|
| D01 | Android beta local-first SQLite, không sync journal đa thiết bị | Dùng offline tốt, ít rủi ro migration; mất dữ liệu khi uninstall/clear storage. Cloud-authoritative tăng chi phí sync và conflict nhưng hỗ trợ nhiều thiết bị |
| D02 | Giữ Home/Check-in/Profile/Auth; ẩn Meals/Rewards khỏi navigation beta, vẫn cho mở dữ liệu cũ qua mục phụ Profile; research tiếp tục ẩn | Core tập trung hơn; thay vị trí tính năng quen thuộc. Không xóa dữ liệu/code |
| D03 | Tuần thứ Hai 00:00 đến thứ Hai kế, timezone IANA cố định theo chuỗi commitment; đổi timezone có hiệu lực kỳ kế, có preview | Dễ so sánh; khi đi du lịch giờ địa phương có thể khác giờ kế hoạch |
| D04 | Tuần đầu là partial, target người dùng chọn giữ nguyên, loại khỏi KPI full-week; repeat cần xác nhận, không tự tạo tuần thiếu tương tác | Không tự áp cam kết; báo riêng tỷ lệ không tạo tuần tiếp thay vì che churn |
| D05 | Buổi hợp lệ ≥10 phút; phiên ngắn recovery ≥5 phút chỉ khi chọn trước khi tập; nhiều buổi/ngày hợp lệ nếu thực sự khác nhau | Đây là định nghĩa sản phẩm để duyệt, không là khuyến nghị y tế; threshold khác sẽ đổi KPI/policy version |
| D06 | Grace 2 giờ sau giờ kết thúc dự kiến; nhắc recovery tối đa một lần mỗi episode, tối đa một/ngày, giờ yên lặng 21:00–08:00 | Ít làm phiền; detection trên máy có thể muộn khi app tắt |
| D07 | Không dời cùng session sang tuần khác; tạo buổi mới có liên kết nguồn ở tuần mới và giữ kết quả tuần cũ | Không chuyển công giữa mẫu số; thêm một bước xác nhận |
| D08 | Backdate/correction được sửa KPI tới 7 ngày sau week end; sau đó vẫn lưu log/correction nhưng KPI snapshot khóa | Dữ liệu đo ổn định; cần hiển thị khác biệt giữa lịch sử cập nhật và báo cáo đã khóa |
| D09 | Rest không tính completion, không giảm target; health rest dừng mọi nhắc vận động tới khi người dùng chủ động bật lại | Không thúc ép; adherence không được “bù” vì nghỉ, phải trình bày trung tính |
| D10 | Guest và account tách biệt; không tự merge; nền tảng Preferences giữ tính năng cũ, chưa bật engine mới | Không mất dữ liệu/giả atomic; chưa có parity web/desktop |
| D11 | Analytics opt-in riêng, retention raw 90 ngày; consent withdrawal purge queue và yêu cầu xóa dữ liệu server; không nối guest/account subjects | Mẫu có selection bias, không theo dõi xuyên identity; cần báo consent coverage |
| D12 | Recovery action completion KPI chỉ tính hành động vận động đã hoàn thành; rest acknowledgment báo riêng | Không nhầm chọn nghỉ với tập xong; cần duyệt semantics so với roadmap |
| D13 | Dùng định nghĩa cohort, censoring, repeat-gap và ngưỡng KPI trong analytics.md; consented device-owner là đơn vị beta | Không coi reinstall/đa máy là cùng một người; beta cần quy ước một installation/người |

**Architecture gate:** chủ sản phẩm xác nhận từng D01–D13 hoặc ghi phương án sửa.
Sau đó cập nhật ADR thành Accepted với ngày, người duyệt và version trước PR1.
Không triển khai Commitment Engine, domain code mới, migration hoặc production
trước gate. PR0 không thay thế phỏng vấn 10–15 người, ≥8 xác nhận vấn đề, hay prototype
end-to-end; các bằng chứng này hiện **chưa đo/chưa thực hiện**.
