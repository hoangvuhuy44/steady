# PR0 — Source evidence và kiểm chứng

Ngày 05/11/2026, Asia/Bangkok. Base SHA `5fd636334e86c71582b6ae62a858d1d183eb62db`.
Repo ban đầu sạch, branch `feature/steady-brand-identity`; không thấy AGENTS.md trong
repo hoặc các thư mục cha C:/, C:/Code/, C:/Code/Steady/. Không lấy AGENTS.md ở thư mục
ChatGPT khác làm instruction cho repo này. Branch PR0 riêng `docs/pr0-mvp-architecture`.

## Source được đối chiếu lại

| Phạm vi | Evidence / kết luận hiện tại |
|---|---|
| Entry | `lib/main.dart`: bắt lỗi init Supabase, await native reminder initialize trước runApp chưa catch; rủi ro startup, không phải crash đã tái hiện |
| Routing | `lib/app/steady_app.dart`: IndexedStack Home, Check-in, Meals (DailyMenu hoặc Recipes), Rewards, Profile; auth revision/lifecycle/reminder sync; research không route |
| Activity model | `lib/models/activity_type.dart`: 8 môn, ActivityLog id/owner/type/minutes/createdAt UTC/localDate; không session/actual completed timestamp |
| Metrics | `lib/models/activity_metrics.dart`: rolling 7 calendar dates, distinct activeDays, targetDays=5, streak; không weekly adherence |
| Persistence | `lib/data/activity_repository.dart`: SQLite v2 + device_identity transaction, v1 upgrade, legacy integer timestamps; Preferences từng key trên web/Windows/Linux, không multi-entity transaction |
| Store | `lib/state/steady_store.dart`: UUID mỗi log, activitySaving, _pendingWrite, revision guards; không session-level idempotency qua restart |
| Auth | `lib/auth/auth_controller.dart`: Supabase session/userId + sessionRevision, unconfigured guest path; sign-in không sync journal |
| Reminders | `lib/reminders/native_reminders.dart`: morning/evening zonedSchedule, DateTimeComponents.time, payload check-in; cancel/serialized scheduling/cache. `reminder_controller.dart` owner/retry/permission logic |
| Backend | Ba migrations: `20261022042606_workout_reminders.sql` legacy private delivery/FCM RPC; `20261022090114_food_personalization.sql` RLS + revision CAS; `20261025094420_local_workout_notifications.sql` public workout_reminders + owner RLS + per-owner retire push |
| SQL runtime | Source có grants/revokes, auth guards, invoker/definer; chưa chạy staging tests/deployment verification; tuyệt đối không suy source = deployed |
| Tests | ActivityMetrics, SQLite FFI migration/reopen/owner isolation, Preferences, store rapid saves/stale async, auth, reminders, widgets, research/nutrition. Chưa có commitment/recovery tests |
| Android | app namespace/applicationId com.example.steady; Java/Kotlin 17; AGP 9.1.0, Kotlin 2.4.0; SDK từ Flutter; release đang debug signing; manifest notification/boot receivers, auth callback |
| CI | Không có thư mục .github trong baseline; không có integration_test được track |

Guest Preferences initialization là read-then-write, có rủi ro concurrency hai tab;
chưa tái hiện. SQLite guest identity dùng transaction nên không đồng nhất hai cơ chế.
Native scheduling chỉ hỗ trợ local daily; legacy worker/SQL còn trong repo không
chứng minh FCM đang dùng cho app hiện tại.

## Lệnh chạy hiện tại

Flutter gọi qua Dart executable + flutter_tools.snapshot cùng SDK để tránh bootstrap
batch; tương đương CLI dưới đây. SDK nằm tại Downloads/flutter_windows_3.47.5-stable/flutter.
Sandbox chặn SDK cache/lockfile lúc đầu; đã chạy lại với quyền truy cập SDK được cấp.

| Kiểm tra | Kết quả PR0 hiện tại |
|---|---|
| `git status --short`, branch, rev-parse HEAD | Ban đầu sạch; đúng base SHA audit |
| `flutter --version` | Thành công: Flutter 3.47.5, Dart 3.13.4 |
| `flutter analyze --no-pub` | PASS, No issues found, exit 0, 13.7 giây |
| `flutter test --no-pub --reporter expanded` | PASS: 172 passed, 1 skipped, exit 0; suite 53 giây. Browser-only `web_activity_widget_test.dart` skipped trên host |
| `flutter build apk --debug --no-pub` | PASS, exit 0; assembleDebug 64.7 giây; `build/app/outputs/flutter-apk/app-debug.apk` được tạo. Có warning SDK XML v4/parser v3 và Java native access, không làm build thất bại |
| Web browser / iOS / release APK | NOT RUN trong PR0 |
| Android runtime ≥3 configs | NOT RUN; chưa chứng nhận beta readiness |
| SQL/Edge/staging auth/RLS | SOURCE REVIEW ONLY; không chạy migration/production |
| Acceptance AC01–AC34 mới | PLANNED / NOT RUN; PR0 không triển khai engine |
| Research/2-minute usability/beta metrics | Chưa đo |

Báo cáo audit trước ghi 172 passed/1 skipped và APK loopback failure. Đó là kết quả
lịch sử ở clone audit, không dùng thay kết quả PR0. `docs/ANDROID_APK_BUILD_REPORT.md`
ghi version 1.0.0+1, khác pubspec HEAD 1.1.0+3; đã gắn nhãn historical.

Lần chạy hiện tại không tái hiện lỗi loopback; không đổi JDK/Gradle/dependency để
làm build qua. APK debug build thành công không thay cho cài/chạy trên ba cấu hình
Android hoặc release signing. Artifact nằm trong build/ và không được đưa vào PR.

Kiểm tra tài liệu: relative Markdown links trong docs/mvp resolve; diff whitespace
được kiểm tra; phạm vi thay đổi chỉ Markdown. Remote base được kiểm tra bằng
`git ls-remote origin refs/heads/feature/steady-brand-identity`, vẫn cùng SHA audit.
