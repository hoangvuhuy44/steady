# PRD delta và user flows

Trạng thái: đề xuất, phụ thuộc [D01–D13](README.md). Mục tiêu là giữ cam kết tuần và
quay lại sau buổi lỡ; không xây fitness super-app. Android-first, guest dùng core.

## Inventory và quyết định navigation

| Màn hình/luồng hiện có | Bằng chứng trong repo | Đề xuất beta sau gate |
|---|---|---|
| Home | `lib/screens/home_screen.dart`, ActivityMetrics rolling 7 ngày | **Giữ, sửa input:** tuần cố định, target snapshot, progress; streak/points chỉ thông tin phụ |
| Check-in | `lib/screens/check_in_screen.dart`, 8 môn, 10–120 phút | **Giữ, mở rộng:** chọn session hoặc log tự do, thời gian thực tế tách thời gian nhập |
| Recipes, detail, filter | `lib/screens/recipes_screen.dart`, `lib/recipes/recipe_filter.dart` | **Ẩn khỏi tab chính**, mở qua mục phụ Profile; hoãn mở rộng |
| Daily menu/questionnaire | `lib/personalization/`, route ở tab Meals/Profile; guest/account persistence thật | **Ẩn khỏi tab chính**, bảo toàn quyền mở dữ liệu cũ ở mục phụ; không gọi là mock/UI-only |
| Rewards | `lib/screens/rewards_screen.dart`, points thật, reward preview | **Ẩn khỏi tab chính**, giữ mục phụ; hoãn redeem. “Recovery day” không phải rest nghiệp vụ |
| Profile/language | `lib/screens/profile_screen.dart`, VI/EN có persistence | **Giữ**; thêm consent/tuần/timezone; ActivityGoal hiện chưa chỉnh được target |
| Sign-in/up/out | `lib/screens/sign_in_screen.dart`, AuthController | **Giữ tùy chọn**, giải thích journal local riêng mỗi identity; không hứa cloud backup |
| Reminder settings | `lib/reminders/reminder_screen.dart` | **Giữ**, thay lịch theo session trong PR5; guest support là phần mới, không có sẵn |
| Screening/research meals | `lib/screens/screening_screen.dart`, `lib/research/` | **Tiếp tục ẩn**, chưa route từ app; không xóa model/test |
| Onboarding commitment | Chưa có | **Thêm PR2**, target 1–7 và đa môn; preview tuần đầu |
| Weekly planner/progress/review/repeat | Chưa có | **Thêm PR3**, phân biệt dự kiến và thực tế |
| Recovery choices | Chưa có | **Thêm PR4**, dời/phiên ngắn/nghỉ, không guilt copy |
| Share card/nhóm tự nguyện | Chưa có | **Hoãn core**, prototype PR5, beta có consent riêng PR6 |
| Rule-based planning | Chưa có fitness planning | **Hoãn core**, prototype nội bộ PR5; không meal planning/LLM |

PR0 không thực hiện thay đổi navigation. Reuse theme/tokens/fonts/logo/VI-EN,
ChangeNotifier, test clocks/fakes; không đổi framework state.

## Luồng chính và trạng thái lỗi

1. **Vào app:** đọc owner, dữ liệu local; lỗi mở DB có retry, không hiện progress 0
   thay cho lỗi. Native reminder lỗi vẫn phải cho vào core ở PR5.
2. **Thiết lập:** chọn guest/account tùy ý; consent analytics tách khỏi sử dụng app.
   Chọn timezone, 1–7 buổi, nhiều môn; xem tuần hiện tại là partial nếu có.
   Persist commitment rồi mới báo thành công. Lỗi ghi giữ draft, retry cùng command ID.
3. **Lên lịch:** planner cho thêm/sửa/xem/hủy buổi. Target không đổi khi số lịch đổi.
   Có thể lên nhiều buổi/ngày; không ép đủ lịch ngay. Kiểm tra giờ kết thúc trong tuần.
4. **Ghi hoạt động:** chọn lịch hoặc log tự do; nhập actual completion, thời lượng,
   môn. Transaction lưu log + credit + session + outbox. Retry trả cùng kết quả;
   không phát success/event trước commit. Buổi dưới ngưỡng vẫn là nhật ký thật nhưng
   không có credit; UI giải thích và không ép kéo dài tập.
5. **Bỏ lỡ:** clock vượt deadline, reconcile khi mở/resume. Nếu người dùng báo đã
   tập đúng giờ thì cho backdate, correction ghi rõ; không bắt chọn recovery trước.
6. **Recovery:** dời trong tuần giữ session/target; chọn phiên ngắn giữ cùng credit
   root; nghỉ chủ đích/health rest không tạo activity. Lỗi lưu không hủy lịch gốc.
   Dời qua tuần cần xác nhận tạo buổi mới thuộc commitment mới, không “cứu” tuần cũ.
7. **Review:** hiển thị số buổi hợp lệ / target cố định, log dưới ngưỡng, rest và
   pending correction riêng. Không biến rest thành thất bại đạo đức. Nếu chưa có
   commitment, hiển thị nhật ký lịch sử, không tự suy diễn target.
8. **Tuần tiếp:** người dùng xác nhận repeat hoặc đổi target/môn/lịch. Pending target
   chỉ áp dụng tuần mới; unique owner + week chống repeat hai lần. Nếu bỏ qua nhiều
   tuần, không tự dựng commitments lịch sử từ logs; hiển thị khoảng trống.

## Guest / account / offline / bất đồng bộ

| Tình huống | Hành vi được đề xuất |
|---|---|
| Guest → sign-in | Đóng route nhạy cảm cũ, cancel reminders cũ, đổi owner; không chuyển logs/commitments; thông báo dữ liệu guest còn trên máy |
| Sign-out/account switch giữa save | Command đã bắt đầu giữ owner cũ, serialize xong rồi đọc owner mới; response cũ không cập nhật UI mới; analytics uploader chỉ gửi owner đang active |
| Auth hết hạn/offline | Core trên partition hiện tại vẫn local; không đổi owner do lỗi mạng tạm thời; thao tác backend báo retry, không hứa sync journal |
| Mất mạng sau save | Core đã hoàn thành; outbox pending tự retry khi consent còn hiệu lực; không lưu lại activity |
| Crash trước/sau commit | Trước: rollback toàn bộ; sau: command receipt trả kết quả cũ, outbox được gửi lại với event_id cũ |
| Hết dung lượng/lỗi DB | Không partial success; giữ input, báo không lưu được và retry; không có analytics success |
| Notification bị từ chối | Planner/recovery trong app vẫn dùng; không hỏi lại mỗi resume; mở settings chỉ theo thao tác người dùng |
| Health rest | Dừng nhắc vận động ở owner hiện tại kể cả buổi tương lai; người dùng chủ động resume, không tự bật lại vì rollover |
| Web/Windows/Linux | Giữ Preferences activity flow hiện hữu; không tạo commitment đa bảng qua các key rời rạc |

Ví dụ: target 3, đã hoàn thành 1, dời buổi thứ hai sang thứ Sáu: vẫn 1/3.
Hoàn thành phiên ngắn hợp lệ của buổi đó: 2/3. Chọn nghỉ buổi thứ ba: vẫn 2/3.
Một log thứ hai cho cùng credit root không tăng 3/3. Một buổi tự do khác thật sự
hợp lệ có thể đưa lên 3/3; credit không vượt 100% dù người dùng tập thêm.
