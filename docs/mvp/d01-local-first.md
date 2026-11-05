# D01 — Android beta local-first SQLite

Accepted ngày 05/11/2026 theo yêu cầu trực tiếp của chủ sản phẩm. Base triển khai
là D02 `1128d7c`. D03–D13 còn chờ duyệt; đây không phải PR1/PR2 hay toàn bộ architecture gate.

## Hợp đồng đã xác nhận

- Journal Android có một nguồn chuẩn: `steady_activities.db` SQLite v2 trên mỗi
  installation. `createActivityRepository()` chọn `SqliteActivityRepository` trên
  Android; không có remote activity repository, upload/download journal hoặc sync queue.
- Save/load journal không cần Auth client hay network. Auth chọn partition local
  theo user ID; cùng tài khoản trên hai installation vẫn có hai journal độc lập.
- Guest identity, partition account/guest và dữ liệu ActivityLog v2 giữ nguyên.
  D01 không tự gộp guest/account hoặc suy diễn commitments từ logs.
- Thành công chỉ sau persistence; lỗi mở/ghi DB được báo, không fallback sang RAM
  rồi giả thành công. SQLite reopen/migration/owner isolation tests tiếp tục áp dụng.
- Profile và màn hình đăng nhập VI/EN nói rõ journal không sync khi đăng nhập.
  Profile giải thích gỡ app/xóa dữ liệu có thể làm mất nhật ký vĩnh viễn.

Code lưu trữ này đã tồn tại trước D01; thay đổi lần này xác nhận bằng tests, cập nhật
copy sản phẩm và quyết định ADR, không dựng thêm repository hoặc đổi schema vô ích.
Chưa có journal cloud backup/restore của Steady. Không hứa bảo toàn journal qua
uninstall, clear storage, mất máy hoặc đổi máy. Backup/restore ở cấp hệ điều hành
không thuộc sync của Steady và không được chứng nhận trong PR này; không đổi Android
backup policy hoặc xóa các bản backup có thể đang tồn tại.

Supabase Auth, food personalization và reminder settings hiện hữu không phải journal
sync; PR này không thay đổi các module đó. Web/Windows/Linux giữ adapter Preferences
hiện tại; không mở engine mới trên các nền tảng này. Analytics/outbox, core transaction
mới, Commitment/Recovery migrations vẫn chờ gate đầy đủ.

## Verification và giới hạn

Hai test bổ sung dùng factory Android và SQLite FFI thật: chọn đúng backend; hai
database giả lập hai installation đăng nhập cùng account ghi hoạt động khác nhau,
không nhìn thấy journal nhau, giữ riêng guest IDs sau close/reopen. Không khởi tạo
Supabase client hay cần kết nối mạng trong test journal này. Đây là host integration
test, không thay kiểm thử airplane mode/reinstall/two-device trên Android thật.

Các test v1→v2, reopen, owner isolation, write failure và stale auth responses vẫn
được giữ. Kết quả thực thi cuối và ảnh VI/EN nằm trong mô tả PR.

Kiểm chứng host ngày 05/11/2026:

- `flutter gen-l10n`: thành công, bản dịch sinh từ ARB VI/EN.
- `flutter analyze --no-pub`: No issues found.
- `flutter build apk --debug --no-pub`: thành công, assembleDebug 184.7 giây;
  chưa cài/chạy APK trên thiết bị thật.
- `flutter test test tool/brand_visual_review_test.dart --no-pub --reporter expanded`:
  175 passed, 1 skipped (browser-only), bao gồm hai test D01 và một visual capture test.
- Ảnh [Profile VI](../screenshots/brand/vi-profile.png) và
  [Sign-in EN](../screenshots/brand/en-sign-in.png) được rà trực quan; test layouts
  với chữ lớn tiếp tục pass. Không nâng dependency để chạy test.

## Data impact / rollback

Không migration, không đổi database filename/version/fields, không backfill/xóa logs,
không thêm dependencies hoặc production backend. Revert commit D01 chỉ khôi phục
copy/docs/tests; dữ liệu local không bị ảnh hưởng. Muốn sync/backup journal sau beta
cần quyết định riêng về ownership, consent, conflict và migration trước triển khai.
