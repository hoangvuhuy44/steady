# Workout reminders: local notifications + Supabase

Ngày kiểm tra: 25/10/2026. Flutter 3.47.5, Dart 3.13.4, Windows/Android SDK.

## Đã triển khai

- Giữ màn hình Workout reminders trong Hồ sơ → Nhắc nhở; không có ảnh tham chiếu và không tìm thấy AGENTS.md trong repository hoặc các thư mục cha liên quan.
- Hẹn local Android/iOS bằng flutter_local_notifications 19.5.0 và timezone 0.10.1, mặc định 07:00/18:30 Asia/Ho_Chi_Minh, ID ổn định, gửi thử hoàn toàn local, hủy lịch khi tắt/đổi tài khoản.
- Xin quyền khi bật/gửi thử, kiểm tra cả quyền ứng dụng và notification channel. Lỗi quyền, lưu cache, sync và hẹn lịch được hiển thị riêng. Không báo thành công trên máy khi hẹn lỗi.
- Cache riêng tài khoản, pending được lưu bền, áp dụng offline trước khi sync. Sync startup/foreground/thủ công và retry 30 giây khi tiến trình còn chạy. Pending ghi trước khi đọc server; lần ghi server nhận sau cùng thắng.
- Chặn phản hồi muộn bằng kiểm tra phiên và hàng đợi native; đăng xuất không phải đợi request mạng cũ hoàn tất.
- Migration bảng public.workout_reminders, RLS sở hữu và UPDATE USING/WITH CHECK, validation server, sao chép lịch cũ. Cutover theo tài khoản hủy các lượt FCM cũ chưa gửi khi sync/ghi thành công.
- Bỏ Firebase dependencies, Dart listeners/token, Gradle Google Services, manifest metadata và iOS push entitlement. Worker entry point trong source trả HTTP 410; không thay đổi production.
- Android channel/icon/desugaring/boot receivers và giữ resource icon; iOS notification delegate. InexactAllowWhileIdle có thể trễ do tiết kiệm pin.

## Kiểm tra

Các file chính đã sửa:

- `lib/reminders/reminder_controller.dart`, `native_reminders.dart`, `reminder_screen.dart`: cache/sync, lịch local và UI.
- `lib/app/steady_app.dart`, `lib/screens/profile_screen.dart`: startup/foreground, thay tài khoản, mở thông báo, đăng xuất.
- `pubspec.yaml`, `pubspec.lock`: thay Firebase bằng local notifications/timezone; các registrant/plugin list được Flutter tạo lại trong macos/windows.
- `android/app/build.gradle.kts`, `android/settings.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/raw/keep.xml`: desugaring, receiver, icon và bỏ Google Services.
- `ios/Runner/AppDelegate.swift`, `Info.plist`, `Runner.entitlements`, `ios/Runner.xcodeproj/project.pbxproj`: local delegate và bỏ cấu hình remote push.
- `supabase/migrations/20261025094420_local_workout_notifications.sql`, `supabase/functions/reminder-worker/index.ts`, `supabase/schedule.example.sql`: schema/RLS/cutover và nghỉ worker.
- `test/reminder_controller_test.dart`, `test/native_reminders_test.dart`, `test/widget_test.dart`, `tool/verify_local_reminder_sql.mjs`: kiểm thử.
- `docs/workout-reminders.md`, báo cáo này, `README.md`, `reminder-config.example.json`, `.gitignore`: hướng dẫn/cấu hình mẫu và bỏ qua build cache Kotlin.

- `flutter pub get`: thành công, cập nhật pubspec.lock.
- `flutter analyze`: No issues found.
- `flutter test --concurrency=2`: **172 passed, 1 skipped**, không có lỗi. Test bị bỏ qua là web_activity_widget_test, chỉ chạy trên web (`skip: !kIsWeb`). Test khởi động đã mock đăng ký plugin native mới; không gọi FCM.
- Test nhắc tập: đổi giờ/múi giờ, giờ sai/trùng, quyền bị từ chối, lỗi hẹn, offline/pending/retry, cache tách tài khoản, logout và owner change khi sync đến muộn, native queue khi logout giữa await, gửi thử không gọi server.
- `node tool/verify_local_reminder_sql.mjs`: **25 kiểm tra** trên PostgreSQL nhúng qua cả migration cũ và mới; RLS, chặn đổi chủ, validation, quyền anon và cutover theo tài khoản khi pull/upsert. Không kết nối production. Docker daemon chưa chạy nên không chạy được Supabase local đầy đủ/advisors.
- `flutter build apk --debug --dart-define-from-file=supabase-config.json`: thành công. APK: `build/app/outputs/flutter-apk/app-debug.apk`. Gradle có cảnh báo native-access của JDK; build vẫn hoàn tất.
- `git diff --check`: không có lỗi whitespace.

## Còn cần thực hiện

1. Áp dụng migration lên đúng Supabase project và kiểm tra API/RLS với hai tài khoản thật. Chưa áp dụng migration hoặc thay đổi job production trong phiên này.
2. Kiểm tra phạm vi cron steady-workout-reminders, reminder-worker và scheduler ngoài; ngừng job/triển khai entry point nghỉ hoạt động sau khi xác nhận rollout. Client cũ có thể đăng ký FCM lại, cần cập nhật thiết bị hoặc dừng worker đã xác định phạm vi. Push đã gửi không thể thu hồi.
3. Cài APK lên điện thoại, kiểm tra cấp/từ chối quyền, background, offline, reboot, đổi giờ, tắt, hai thiết bị và đăng xuất. Chưa kiểm thử điện thoại thật; fake plugin không chứng minh OS đã hiển thị.
4. iOS cần macOS/Xcode và thiết bị iOS để build/kiểm tra. Khi phát hành Android cần signing key chính thức; cấu hình release cũ vẫn đang dùng debug signing.

Hướng dẫn SQL, build/cài và checklist điện thoại: [workout-reminders.md](workout-reminders.md).
