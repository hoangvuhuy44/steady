# D03 — Tuần, timezone thiết bị và chuỗi commitment

**Accepted ngày 06/11/2026:** người dùng xác nhận tuần thứ Hai 00:00 đến thứ Hai kế,
timezone IANA cố định theo thiết bị và chuỗi commitment; đổi timezone ở kỳ kế có
preview. Người dùng chọn “Dùng kỳ chuyển tiếp liền mạch như đề xuất”.

PR này chỉ cập nhật hợp đồng thiết kế sau D01/D02, base `7e08356`. App chưa có
Commitment/Schedule Engine, nên chưa có màn hình preview chạy được, schema thực thi
hay lịch tuần mới trong runtime. Không đổi ActivityMetrics rolling 7 ngày, ActivityLog
v2 hoặc hai nhắc daily hiện hữu. D04–D13 vẫn pending theo architecture gate.

## Quy tắc đã chốt

1. Khi khởi tạo chuỗi, lấy IANA timezone từ cài đặt timezone hệ điều hành của thiết
   bị. Không suy từ locale/ngôn ngữ, vị trí IP, chữ viết tắt hay UTC offset hiện tại.
   Ví dụ người dùng chọn tiếng Việt trên máy ở Berlin vẫn có zone Europe/Berlin.
2. Snapshot zone cho chuỗi và mỗi kỳ. Tuần bình thường dùng khoảng nửa mở
   `[thứ Hai 00:00, thứ Hai kế 00:00)`. Instant đúng end thuộc kỳ tiếp theo.
   Tính hai mốc theo lịch trong zone, không lấy start + 168 giờ.
3. Đổi timezone của máy không rewrite start/end, lịch buổi, logs hay lịch sử kỳ đang
   diễn ra. UI phải phân biệt giờ kế hoạch trong zone chuỗi và giờ thiết bị nếu khác.
   Cùng IANA ID nhưng đổi offset do DST không phải yêu cầu đổi timezone chuỗi.
4. Thay đổi zone được preview cho kỳ kế; thời điểm hiệu lực là end đã lưu của kỳ cũ.
   Kỳ chuyển tiếp bắt đầu đúng instant đó, kết thúc ở thứ Hai 00:00 đầu tiên trong
   zone mới có instant **strictly greater than start**. Nếu start chính là Monday
   00:00 mới, chọn Monday kế tiếp để kỳ có độ dài dương.
5. Kỳ chuyển tiếp có thể chỉ vài giờ. Không tự cộng thêm 7 ngày để làm nó “đủ tuần”.
   Preview phải hiển thị ngày/giờ ở cả zone cũ và mới, UTC offset tại từng đầu mốc,
   tổng giờ thực tế và nhãn “Kỳ chuyển tiếp”. Sau nó, các kỳ bình thường lại là
   Monday–Monday trong zone mới. Không có instant nào được tính vào hai kỳ.
6. Không thay target, tính validity, tự repeat hay sửa adherence trong D03. Target
   cho kỳ rất ngắn, first partial week/repeat thuộc D04; KPI/cohort thuộc D13. Đây
   vẫn là các quyết định cần chốt trước engine, dù ranh giới thời gian đã được duyệt.

## Luồng preview và lỗi — hợp đồng triển khai sau gate

- Đọc zone ở setup, app resume và khi nhận thông báo timezone thay đổi. Đầu vào phải
  là ID có trong tz database được app hỗ trợ; không dùng offset để đoán thành phố.
- Khi device zone khác zone chuỗi, tạo candidate preview; người dùng xem và xác nhận
  “Áp dụng từ kỳ kế tiếp”, hoặc giữ zone cũ. Phát hiện zone không tự thay lịch hiện tại.
- Pending change gồm old/new zone, expected chain revision, kỳ nguồn và effective UTC
  boundary. Không persist một candidate chưa xác nhận thành quyết định đã có hiệu lực.
- Trước commit, kiểm tra lại owner, revision và thời điểm. Nếu đã rollover, zone máy
  lại đổi, hoặc tzdb resolution thay đổi so với preview, yêu cầu preview mới; không áp
  thay đổi vào kỳ đã bắt đầu. Hủy pending trước hiệu lực giữ nguyên zone chuỗi.
- App đóng qua boundary: khi mở lại dùng effective boundary đã lưu để reconcile;
  không lấy now làm start. D03 không cho phép tự tạo các commitment bị bỏ qua; quy
  tắc repeat/materialization sẽ do D04 quyết định.
- Không đọc được ID/ID không hỗ trợ: giữ zone chuỗi hiện hữu, không fallback im lặng
  sang UTC/Asia/Ho_Chi_Minh. Với chuỗi mới, giữ draft và cho retry, chưa commit kỳ
  mà zone không xác định. Journal hiện hữu vẫn hoạt động.
- Không tự dịch hoặc copy các buổi đã lên lịch qua ranh giới tuần. Preview chỉ nêu
  tác động mốc kỳ; reschedule/cross-week activity thuộc D07 và PR planner sau gate.
- Giờ wall-clock không tồn tại/trùng do DST: phương án resolver từ ADR (dịch tới
  phút hợp lệ đầu tiên/chọn offset sớm hơn, preview rõ) vẫn phải được kiểm thử khi
  triển khai. Không sử dụng DST để sửa lại UTC instant của kỳ đã được persist.

## Ví dụ chính xác để review

Các mốc dưới đây được kiểm tra bằng Python zoneinfo, package tzdata 2025.3 trên host,
với 5 assertions cho 3 chuyển zone và 2 tuần DST; không phải runtime
Schedule đã triển khai. Tuần đang chạy kết thúc Monday 16/11/2026 00:00 ở zone cũ.

| Zone cũ → mới | Start kỳ mới trong zone mới | End kỳ mới trong zone mới | UTC interval | Thời lượng |
|---|---|---|---|---|
| Bangkok → Berlin | CN 15/11 18:00 +01 | T2 16/11 00:00 +01 | [15/11 17:00Z, 15/11 23:00Z) | 6 giờ |
| Bangkok → Tokyo | T2 16/11 02:00 +09 | T2 23/11 00:00 +09 | [15/11 17:00Z, 22/11 15:00Z) | 166 giờ |
| Berlin → Bangkok | T2 16/11 06:00 +07 | T2 23/11 00:00 +07 | [15/11 23:00Z, 22/11 17:00Z) | 162 giờ |

Bangkok không đổi zone: 09/11 00:00 → 16/11 00:00, 168 giờ.
New York qua DST: 02/03/2026 → 09/03/2026 là 167 giờ; 26/10/2026 → 02/11/2026 là
169 giờ. Cả hai vẫn là tuần bình thường Monday–Monday, không phải timezone_transition.

### Nội dung preview dự thảo (chưa có UI)

VI: “Múi giờ thiết bị: Europe/Berlin. Chuỗi hiện tại: Asia/Bangkok. Tuần hiện tại
giữ nguyên đến 16/11/2026 00:00 +07 (15/11 18:00 +01 tại Berlin). Kỳ chuyển tiếp:
15/11 18:00 → 16/11 00:00 +01, tổng 6 giờ. Từ kỳ sau: thứ Hai 00:00 → thứ Hai 00:00
theo Europe/Berlin.” Nút: “Giữ múi giờ hiện tại” / “Áp dụng từ kỳ kế tiếp”.

EN: “Device time zone: Europe/Berlin. Current commitment series: Asia/Bangkok.
Your current week stays unchanged. Transition period: 15 Nov 2026, 18:00 →
16 Nov, 00:00 (UTC+01), 6 hours. Following weeks run Monday to Monday in
Europe/Berlin.” Buttons: “Keep current time zone” / “Apply next period”.

Preview không hứa tự giảm target cho kỳ 6 giờ; target semantics phải được chốt ở D04.

## Nguồn và kiểm chứng

IANA tz database lưu các quy tắc offset/DST thay đổi theo thời gian, nên cần dùng
zone ID và snapshot UTC boundaries thay vì offset cố định. Đây là cơ sở kỹ thuật;
quy tắc thứ Hai/transition/preview là quyết định sản phẩm của Steady.
[IANA time-zone database](https://data.iana.org/time-zones/tz-link.html).

Đã đọc source: ActivityMetrics vẫn rolling 7 ngày; native reminders vẫn daily fixed
times; dependency timezone 0.10.1 đã có nhưng không có adapter đọc timezone thiết bị
cho Schedule. Những phần này cần triển khai sau gate. Đã tính lại fixtures nêu trên,
rà liên kết Markdown và diff docs-only. Không chạy Flutter tests/build cho PR chỉ
tài liệu, không dùng kết quả D01 để chứng nhận Schedule. Automated acceptance
D03-T01–T12 ở ma trận vẫn **planned/not run**.

Rollback: revert commit tài liệu D03, không data/schema/UI impact. PR phụ thuộc D01;
không merge/deploy hoặc đánh dấu toàn bộ architecture gate Accepted.
