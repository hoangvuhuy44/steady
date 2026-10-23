# Nhắc tập trên điện thoại — MVP

## Stack và lựa chọn

Đã kiểm tra repo và các thư mục cha, không thấy `AGENTS.md`. App Flutter/Dart,
Android/iOS; web chỉ là preview. Có Supabase Auth (email và OAuth), nhật ký SQLite
theo thiết bị/tài khoản, SharedPreferences. Trước thay đổi này chưa có schema
server, worker, cron, Firebase hay hạ tầng deploy notification trong repo.

MVP dùng lại Supabase Auth và Postgres, thêm một Edge Function gửi **remote push**
qua FCM HTTP v1; trên iOS, FCM chuyển tiếp qua APNs. Không dùng Firebase Auth,
Firestore hay backend riêng. Cron chạy mỗi phút, độc lập app. Local notification
cũng phù hợp với hai giờ cố định: hệ điều hành lên lịch ngay trên điện thoại,
ít hạ tầng và có thể nhắc offline. Bản này dùng remote push để quản lý lịch theo
user, nhiều thiết bị, retry và lượt nhắc tập trung theo yêu cầu.

Không có Web Push/PWA trong phạm vi này; web/desktop hiển thị không hỗ trợ.
Không cần VAPID, service worker hay điều kiện Add to Home Screen của iPhone;
những thứ đó thuộc phương án Web Push. iPhone ở đây chạy app Flutter native.

## Hành vi

- Hồ sơ → Nhắc tập. Đăng nhập bằng Supabase; khách vẫn dùng các tính năng cũ,
  cần đăng nhập để bật nhắc. Không có endpoint demo công khai gửi đến các user.
- Mặc định **07:00 / 18:30**, `Asia/Ho_Chi_Minh`, hằng ngày, ban đầu tắt.
  Hai giờ phải khác nhau. Nhập `HH:mm` và bất kỳ múi giờ IANA hợp lệ,
  ví dụ `America/New_York`, `Europe/London`, `Pacific/Auckland`.
- Chỉ **Bật nhắc tập** gọi API xin quyền hệ điều hành. Startup/đọc cài đặt
  không xin quyền. Trạng thái tách chưa cấp, từ chối, đã bật trên máy hiện tại,
  và không hỗ trợ/chưa cấu hình FCM. Thiết bị được thêm khi đã có quyền.
- Lưu giờ đổi lịch tài khoản; **Tắt nhắc tập** tắt trên mọi thiết bị.
  Đăng xuất gỡ thiết bị hiện tại khi JWT còn hiệu lực, không tắt máy khác.
  Khi đã cấu hình FCM, cần mạng để gỡ thiết bị trước khi đăng xuất.
- **Gửi thông báo thử** chỉ xếp hàng cho thiết bị hiện tại. Cron xử lý trong
  khoảng một phút. **Demo: sau 1 phút và 3 phút** tạo hai lượt riêng trên máy này,
  không thay giờ hằng ngày. Sai số cron tối đa khoảng một chu kỳ, chưa gồm độ trễ FCM/OS.
  Test/demo dùng chung giới hạn một yêu cầu mỗi 60 giây/user trong database.
- Background: payload notification để OS hiển thị. Foreground: banner trong app
  có nút mở. Bấm thông báo mở tab **ghi nhận buổi tập** (màn hình hiện có), cả
  khởi động nguội và từ background; chỉ định tuyến khi cùng user đang đăng nhập.
- Nội dung sáng: “Dành chút thời gian vận động sáng nay nhé.”
  Chiều tối: “Tan làm rồi, đến giờ dành thời gian cho buổi tập.”

## Cấu hình app native

1. Tạo/chọn **Firebase project phát triển**. Đăng ký Android package
   `com.example.steady` (giữ ID hiện có), bật Firebase Cloud Messaging API.
   Tải `google-services.json` vào `android/app/google-services.json`.
   Gradle chỉ áp dụng Google Services plugin khi file này tồn tại. File tạo native
   Firebase resources để FCM khởi tạo được khi Android khởi động process nền.
2. Copy `reminder-config.example.json` → `reminder-config.json`, điền các giá trị
   public tương ứng cùng Firebase project/app: API key, app ID, sender ID, project ID.
   Không đặt service account hoặc Supabase service role trong file này.
3. Android cần Google Play services. Chạy:

   ```powershell
   flutter pub get
   flutter run -d <android-device-id> --dart-define-from-file=reminder-config.json
   # APK để cài máy thật:
   flutter build apk --release --dart-define-from-file=reminder-config.json
   ```

   Build không có Firebase config vẫn chạy các tính năng cũ, nhắc tập không khả dụng.
   APK có sẵn trong `dist/` từ build trước chưa chứa tính năng này; phải build lại.
4. iOS cần macOS/Xcode, Apple Developer signing và iPhone thật. Đăng ký bundle ID
   đúng app trong Firebase, dùng app ID/API key của **iOS** trong file define riêng.
   Tải `GoogleService-Info.plist`, thêm vào Runner target bằng Xcode. Bật capability
   **Push Notifications** và **Background Modes → Remote notifications**. Repo đã
   khai báo background mode và entitlements; `APS_ENVIRONMENT` mặc định development,
   đổi sang production cho provisioning/distribution tương ứng. Giữ method swizzling
   của Firebase. Upload APNs authentication key/certificate vào Firebase Messaging.
   Chạy `flutter run -d <iphone-id> --dart-define-from-file=<ios-config.json>`.
   Khi APNs token chưa sẵn sàng, chờ vài giây rồi bấm Bật lại.

Tham khảo [FCM cho Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
[Android Firebase config](https://firebase.google.com/docs/android/setup),
[xử lý thông báo và bấm mở](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages).
SDK Messaging được pin ở 17.0.0. Backend HTTP v1 dùng registration token;
ba lời gọi token cũ có chú thích compatibility vì SDK đã đánh dấu deprecated.
Khi chuyển sang Installation ID cần nâng cả client và target gửi ở backend.

## Database, worker và cron

Không có thay đổi nào tự động áp dụng lên project đang dùng. Chọn **project dev**,
đọc migration trước khi chạy. Schema riêng `reminder_private` không expose qua
Data API, mọi bảng bật RLS; không cấp quyền trực tiếp cho client. RPC user dùng
`auth.uid()` và không nhận `user_id`. RPC worker chỉ cấp `service_role`.
Các function dùng `SECURITY DEFINER` với `search_path=''`, tên schema đầy đủ và
revoke EXECUTE mặc định; đây là lớp API hẹp truy cập schema private.

```powershell
npx.cmd --yes supabase --help
npx.cmd --yes supabase start
npx.cmd --yes supabase migration list --local
# Với local stack mới: áp dụng migration bằng db reset (xóa DB LOCAL).
# Chỉ chạy reset khi chắc không có dữ liệu local cần giữ.
npx.cmd --yes supabase db reset --local
```

Hoặc áp dụng `supabase/migrations/*_workout_reminders.sql` một lần qua SQL Editor
trong project dev đã có Auth. Với DB dev đã có dữ liệu, không dùng reset; dùng
quy trình migration của project. Trỏ app đến cùng project bằng các define public
`SUPABASE_URL` và `SUPABASE_PUBLISHABLE_KEY` (xem `docs/auth-setup.md`).
App yêu cầu publishable key dạng `sb_publishable_...`, không dùng service role.
Điện thoại thật nên dùng URL Supabase dev qua HTTPS. `127.0.0.1` trong file env
chỉ dành cho worker chạy trên máy phát triển; trên điện thoại nó trỏ về chính
điện thoại. Muốn dùng local stack từ điện thoại cần URL HTTPS truy cập được
từ thiết bị và cấu hình Auth callback tương ứng.
Chạy advisors sau khi áp dụng: `supabase db advisors --local` cho local hoặc
`supabase db advisors --linked` khi đã link đúng dev project.

Copy `supabase/.env.example` → `supabase/.env`, điền backend URL/service role,
`REMINDER_WORKER_SECRET` ngẫu nhiên đủ dài và `FCM_SERVICE_ACCOUNT` JSON một dòng.
Service account chỉ cần quyền gửi FCM của project đích; enable HTTP v1 API.
JSON phải giữ các escape `\n` trong private key. Tất cả file secrets được gitignore.
Trong môi trường Edge Functions hosted, URL/service role có sẵn; cấu hình thêm
hai secret tự đặt bằng Dashboard hoặc `supabase secrets set --env-file ...`.

```powershell
# Deno đã cài hoặc thay deno bằng npx.cmd --yes deno
# Worker một lần, phù hợp Task Scheduler/cron riêng chạy mỗi phút:
deno run --allow-env --allow-net --env-file=supabase/.env supabase/functions/reminder-worker/index.ts --once
# HTTP worker standalone:
deno run --allow-env --allow-net --env-file=supabase/.env supabase/functions/reminder-worker/index.ts
# Hoặc Edge Function local (cần Docker/Supabase start):
npx.cmd --yes supabase functions serve reminder-worker --env-file supabase/.env
```

HTTP worker chỉ nhận POST có header `x-reminder-secret`, không dùng JWT user hay
publishable key để chạy lịch. `verify_jwt=false` chỉ bỏ gateway JWT; khóa scheduler
vẫn được handler kiểm tra. Không gọi worker từ frontend.

Khi đã sẵn sàng thử trên dev project, chủ repo có thể deploy function bằng
`supabase functions deploy reminder-worker --project-ref <dev-ref>` rồi cấu hình
Vault và chạy `supabase/schedule.example.sql` để cron gọi mỗi phút. Chỉ chọn một
scheduler chính; nhiều worker vẫn dùng claim chung. Dừng bằng
`select cron.unschedule('steady-workout-reminders');`.
Không có script nào tự deploy hoặc tạo cron trên production.
Tham khảo [Supabase cron + Edge Functions](https://supabase.com/docs/guides/functions/schedule-functions)
và [FCM HTTP v1](https://firebase.google.com/docs/cloud-messaging/send/v1-api).

## Lịch, chống trùng và giới hạn giao nhận

- Tính ngày và thời điểm bằng `AT TIME ZONE` cùng IANA timezone trong Postgres,
  không hardcode UTC+7. Kiểm tra cả hôm nay và hôm trước để không bỏ lượt ngay
  trước nửa đêm. Với DST, theo quy tắc Postgres: giờ không tồn tại được dịch theo
  offset chuẩn; giờ lặp chọn lần theo standard time. Chỉ một lượt cho khung/ngày.
- Khóa unique daily là **user + ngày địa phương + morning/evening**, không chứa
  giờ, revision hay timezone. Một event fan-out thành delivery/event/device.
- Đổi/tắt cài đặt tăng revision và hủy pending/claimed/demo. Nếu chưa bắt đầu
  dispatch, giờ mới có thể thay thế event cũ. Event từng được authorize giữ
`attempted` như tombstone, không mở lại cùng user/ngày/khung kể cả đổi giờ.
  Đây là lựa chọn bảo thủ: worker chết sau authorize trước FCM vẫn không mở một
  lịch mới cùng khung khi user sửa giờ; retry của delivery cũ vẫn có giới hạn.
- Chỉ tạo lượt đến hạn trong **10 phút**, không tạo trước thời điểm bật/đổi cài đặt.
  Pending cũng hết hạn sau 10 phút từ due_at. Payload FCM TTL dùng **thời gian còn
  lại**, APNs expiration cùng hạn. Khởi động lại lâu hơn không gửi dồn backlog.
- `FOR UPDATE SKIP LOCKED` claim tối đa 20 delivery/lượt, lease 2 phút, UUID claim
  mới mỗi lần. Worker cũ không finalize claim mới. Recheck enabled, revision,
  device active, lease và TTL ngay trước network call. Tối đa **3 lần gửi gồm lần
  đầu**, retry 30/60 giây; cron có thể làm tròn lên một phút. Worker chết thì
  lease được reclaim. 429/5xx/timeout retry; lỗi vĩnh viễn fail; FCM `UNREGISTERED`
  vô hiệu hóa token. Token mới được upsert sau refresh/resume.
- `accepted` / `providerAccepted` nghĩa là **FCM đã chấp nhận**, không phải thiết
  bị hiển thị. Không có receipt xác nhận display trong MVP. Timeout/crash sau
  provider nhận nhưng trước commit có thể gây gửi lặp; notification tag/collapse
  giúp gộp trên OS nhưng **không bảo đảm exactly-once delivery**.
- Không thể thu hồi thông báo đã chuyển cho provider, hoặc network request đã
  bắt đầu đúng lúc tắt/đổi lịch. Tắt sẽ chặn các lần chưa dispatch tiếp theo.
  Đổi timezone sang ngày địa phương khác có thể có một lượt ở ngày khác theo
  đúng khóa user/ngày/khung. Không xóa tombstone chỉ vì đổi/tắt lịch hay token.

## Kiểm thử tự động

```powershell
flutter analyze
flutter test
npx.cmd --yes deno task --config supabase/deno.json check
npx.cmd --yes deno task --config supabase/deno.json test
git diff --check
```

Test database chạy migration thật trong PostgreSQL WASM/PGlite, stub riêng bảng
`auth.users` và `auth.uid()` cho test, không gửi network push. Bao phủ IANA,
đổi ngày, DST, hai khung, hai thiết bị, chạy lại scheduler, claim độc quyền theo
trạng thái, đổi lịch chưa gửi/đã gửi, tắt, demo 1/3 phút, rate limit, phân quyền,
retry/lease/claim cũ và token hết hạn. PGlite có một connection: test này chưa
chứng minh cạnh tranh khóa giữa nhiều PostgreSQL session thật. Cần thử bổ sung
trên dev stack bằng hai HTTP worker đồng thời, xem unique key và delivery attempts.

## Checklist điện thoại thật

- [ ] Áp dụng schema dev, FCM/APNs config khớp app, worker + cron chạy độc lập.
- [ ] Cài APK mới/iOS app; vào Hồ sơ → Nhắc tập. Chưa có prompt khi chỉ mở app.
- [ ] Đăng nhập, giữ 07:00/18:30 và Asia/Ho_Chi_Minh hoặc sửa; hai giờ trùng bị chặn.
- [ ] Bấm Bật nhắc tập; từ chối kiểm tra trạng thái; bật lại qua OS khi cần.
- [ ] Bấm Gửi thông báo thử. Đưa app về nền, khóa màn hình; nhận notification.
- [ ] Chờ đủ 60 giây từ test trước, bấm Demo 1/3 phút; ghi thời điểm xếp hàng.
- [ ] Rời app bằng Home, khóa màn hình. Nhận **cả hai** nội dung sáng/chiều tối
  sau khoảng 1 và 3 phút (cộng chu kỳ cron/độ trễ). Không cần mở app để worker chạy.
- [ ] Bấm mỗi notification mở tab ghi nhận buổi tập. Thử cả app nền và app đã bị
  OS kết thúc. Android **Force stop** / iOS vuốt tắt có thể ngăn push đến khi mở lại;
  không dùng force-stop để kết luận đường background hỏng. Kiểm tra DND, quyền
  notification, pin tối ưu và mạng nếu không hiển thị.
- [ ] Bật máy thứ hai cùng user: daily fan-out hai máy; test/demo chỉ máy bấm nút.
- [ ] Đặt demo mới sau cooldown rồi Tắt trước phút đầu: không nhận hai lượt đó.
  Đổi giờ/đổi timezone cũng hủy demo cũ. Thông báo provider đã nhận có thể còn tới.
- [ ] Gửi daily, đổi giờ cùng khung trong ngày rồi chạy cron: không có event mới.
- [ ] Đăng xuất máy A, đăng nhập user B: không điều hướng vào tài khoản A khi bấm
  notification cũ; máy khác của A vẫn đăng ký. Thu hồi quyền trong OS rồi resume:
  máy bị gỡ khỏi gửi, trạng thái từ chối.
- [ ] Dừng worker >10 phút rồi chạy lại: bỏ lượt cũ. Chạy hai worker cùng lúc:
  mỗi delivery chỉ có một claim đang hiệu lực; xem provider ID thay vì suy đoán display.

Quan sát ở SQL Editor dev, không expose token trong log:

```sql
select e.user_id,e.local_date,e.slot,e.kind,e.due_at,e.expires_at,e.cancelled,
       d.device_id,d.state,d.attempts,d.provider_id,d.error_code
from reminder_private.events e join reminder_private.deliveries d on d.event_id=e.id
order by e.due_at desc limit 50;
```

## Bằng chứng kiểm chứng

Xem `docs/WORKOUT_REMINDERS_REPORT.md` cho kết quả lệnh đã chạy và phần còn cần
credentials/deploy/thiết bị thật. Không coi unit test là bằng chứng gửi push thật.
