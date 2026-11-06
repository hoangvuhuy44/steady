# Nhắc tập bằng local notifications và Supabase

Màn hình hiện có: Hồ sơ → Nhắc nhở / Workout reminders. Không có ảnh tham chiếu trong yêu cầu. Android/iOS hẹn hai thông báo lặp mỗi ngày; Supabase lưu lịch theo tài khoản. Mặc định **07:00**, **18:30**, **Asia/Ho_Chi_Minh**; người dùng chủ động bật và cấp quyền. Luồng này không dùng Firebase, FCM token hoặc server để hiển thị thông báo.

## Tạo bảng và chuyển đổi backend

1. Kiểm tra đúng project Supabase, sao lưu trước khi triển khai. Áp dụng migration chưa chạy theo thứ tự trong `supabase/migrations/`, gồm **20261025094420_local_workout_notifications.sql**, bằng SQL Editor hoặc CLI `db push` sau khi kiểm tra project liên kết. Migration mới phụ thuộc schema `reminder_private` từ migration cũ.
2. Bảng `public.workout_reminders`: `user_id`, `enabled`, `morning`, `evening`, `timezone`, `updated_at`. RLS chỉ cho authenticated đọc/thêm/sửa dòng của mình; UPDATE có USING và WITH CHECK; anon không có quyền. Trigger kiểm tra IANA qua `pg_timezone_names`; constraint kiểm tra hai giờ khác nhau, không nhận 24:00 hoặc giây khác 0. App chỉ nhận HH:mm và timezone trong database đóng gói.
3. Migration sao chép lịch cũ. Khi tài khoản gọi `local_reminder_settings()` hoặc ghi lịch mới, backend vô hiệu hóa push devices, events và delivery chưa hoàn tất của **tài khoản đó**, cùng transaction. RPC kiểm tra `auth.uid()`, không nhận user_id từ client. Helper SECURITY DEFINER nằm trong schema private, thu hồi EXECUTE từ public/anon/authenticated; quyền ghi trực tiếp vẫn dùng RLS.
4. Chưa tự thay đổi cron/function production. Kiểm tra cron **steady-workout-reminders** trong `cron.job`, Edge Function **reminder-worker**, scheduler ngoài Supabase và log gửi FCM trước rollout. `supabase/schedule.example.sql` chỉ hướng dẫn kiểm tra/dừng, không tạo cron mới. Entry point worker trong repository đã nghỉ hoạt động (HTTP 410); worker.ts/fcm.ts giữ để đối chiếu triển khai cũ và test lịch sử.
5. Khi xác nhận job chỉ phục vụ nhắc tập, operator có thể dừng job và triển khai entry point nghỉ hoạt động. Client phiên bản cũ có thể đăng ký lại push, nên cập nhật các thiết bị cũ hoặc ngừng worker đã xác định phạm vi trước rollout đầy đủ. Push đã gửi trước transaction chuyển đổi vẫn có thể đến muộn; không thể thu hồi từ server.

Kiểm tra bằng tài khoản A/B: A chỉ thấy dòng A; ghi/đổi user_id sang B bị chặn; giờ trùng, 24:00, có giây hoặc timezone giả bị từ chối. Sau đồng bộ đầu của A, kiểm tra devices A inactive và delivery cũ canceled; B chưa chuyển đổi không bị ảnh hưởng. Script PostgreSQL/RLS độc lập: `tool/verify_local_reminder_sql.mjs`.

Không nhúng service-role/secret key. `supabase-config.json` ngoài git chỉ chứa URL + publishable key theo file example. `reminder-config.example.json` đã rỗng, không cần cho build. Không cần Firebase config/google-services.json hay quyền exact alarm.

## Đồng bộ và offline

- Cache SharedPreferences có khóa riêng theo user_id. Khởi động áp dụng cache trước khi gọi Supabase. Bật/sửa/tắt lưu cache kèm pending trước khi gửi; mất mạng vẫn dùng lịch local và hiển thị pending.
- Đồng bộ khi khởi động, foreground, bấm **Đồng bộ ngay**. Lỗi sync/pending được thử lại mỗi 30 giây khi tiến trình còn chạy. Không có background network worker; khi OS dừng tiến trình, lịch đã hẹn vẫn tồn tại, đồng bộ thử lại lúc mở app.
- Gửi bản pending trước, sau đó đọc server. **Lần ghi được server nhận sau cùng thắng cho toàn bộ lịch**; không dùng đồng hồ thiết bị. Chỉnh sửa offline cũ có thể ghi đè thay đổi ở máy khác khi kết nối lại. Timeout có thể khiến bản ghi đã thành công được gửi lại; upsert cùng user_id có tính lặp an toàn.
- Đăng xuất hủy lịch trên máy và vô hiệu hóa controller cũ; đổi tài khoản dùng cache riêng. Native mutations xếp hàng, kiểm tra phiên trước/sau await, nên phản hồi cũ không cài lại lịch. Nếu hủy gặp lỗi, đăng xuất chủ động báo lỗi. Cache pending của tài khoản cũ giữ để gửi khi đăng nhập lại.
- Tắt ở máy A chỉ hủy trên máy B sau khi B đồng bộ; không thể hủy từ xa khi B offline.

## Cấu hình và giới hạn hệ điều hành

Pin `flutter_local_notifications: 19.5.0`, `timezone: 0.10.1`; đã đối chiếu source/README đúng phiên bản với Flutter 3.47.5 / Dart 3.13.4. Android: channel `workout_local_v1`, drawable `ic_stat_workout` giữ khi shrink resources, Java 17, desugaring 2.1.4, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED và hai receiver hẹn/phục hồi sau reboot/cập nhật app.

ID cố định: 71001 sáng, 71002 tối, 71003 gửi thử. Đổi lịch hủy ID cũ rồi hẹn lại; lỗi một slot hủy cả bộ. Tắt hủy các ID này. Chạm thông báo mở ghi nhận buổi tập khi đang đăng nhập.

Dùng `AndroidScheduleMode.inexactAllowWhileIdle`, `DateTimeComponents.time`, TZDateTime theo IANA. Nhắc vận động không cần xin quyền báo thức chính xác. Doze, tiết kiệm pin hoặc giới hạn của nhà sản xuất có thể trì hoãn; không bảo đảm đúng từng phút. Force-stop, xóa dữ liệu/gỡ app hoặc chặn thông báo có thể ngăn hiển thị; cần mở app và bật/đồng bộ lại. iOS chỉ xin quyền khi bật/gửi thử, có UNUserNotificationCenter delegate.

## Build và cài lại

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=supabase-config.json
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Nếu chữ ký bản cũ khác, cần gỡ trước khi cài; gỡ sẽ xóa dữ liệu local. Khi phát hành, dùng signing key của dự án, build `--release` và thử lại icon/receiver. Cấu hình release hiện vẫn dùng debug signing như repository trước thay đổi; không phát hành với key này.

## Thử trên điện thoại

1. Áp dụng migration, cài APK mới và đăng nhập. Vào Hồ sơ → Nhắc nhở; mở màn hình không tự xin quyền. Bấm **Gửi thông báo thử**: Android 13+ hỏi quyền rồi hiển thị local, kể cả chưa bật lịch; không gọi Supabase.
2. Từ chối quyền: không báo đã bật trên máy, có lỗi quyền. Cấp lại trong Cài đặt rồi thử lại.
3. Bật mặc định hoặc chọn hai giờ sắp tới. Đưa app xuống nền, tắt mạng và chờ; chấp nhận độ trễ inexact alarm. Thử reboot sau khi đã hẹn; kiểm tra icon và chạm mở ghi nhận tập.
4. Đổi giờ nhiều lần: chỉ còn hai lịch mới. Tắt rồi chờ giờ cũ: không nhận. Nhập giờ trùng, 24:00, 7:00 hoặc timezone giả: bị từ chối.
5. Offline: sửa/bật/tắt phải có pending; khởi động lại offline giữ lịch đúng tài khoản. Bật mạng, đồng bộ/foreground và kiểm tra pending hết khi ghi/đọc thành công.
6. Hai máy cùng tài khoản: sửa A, đồng bộ B để thay lịch B. Sửa cả hai, đồng bộ lần lượt để kiểm tra quy tắc lần ghi server sau cùng thắng.
7. Đăng xuất/đổi tài khoản khi đang sync: lịch cũ bị hủy, phản hồi muộn không hẹn lại; tài khoản mới không dùng cache cũ. Thử đăng xuất khi mất mạng.

Test fake plugin và PostgreSQL nhúng không chứng minh hệ điều hành hiển thị thật. Windows không build được iOS; cần macOS/Xcode và máy iOS để xác nhận.

Tài liệu đối chiếu: [plugin 19.5.0](https://pub.dev/packages/flutter_local_notifications/versions/19.5.0), [timezone 0.10.1](https://pub.dev/packages/timezone/versions/0.10.1), [Supabase Dart upsert](https://supabase.com/docs/reference/dart/upsert), [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).
