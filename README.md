# Steady

Ứng dụng Flutter ghi nhận vận động và lập thực đơn mẫu với món Việt. Giao diện
hỗ trợ đầy đủ tiếng Anh và tiếng Việt, gồm cả công thức, nguyên liệu và thông báo.

## Đăng nhập và sàng lọc sức khoẻ

Steady dùng Supabase Auth (email/mật khẩu, Google và Facebook). Ưu tiên bật email
trước; Google/Facebook chỉ hoạt động sau khi cấu hình provider tương ứng.
Sau mỗi lần đăng nhập, người dùng
hoàn thành screening về bệnh nền, dị ứng và tình trạng điều trị trước khi vào app.
Kết quả xác định phạm vi hỗ trợ của mục Bữa ăn; dữ liệu sức khoẻ chỉ giữ trong phiên.

Cấu hình công khai của project Steady đã có sẵn trong app. Clone sang máy khác
không cần file JSON cục bộ; chạy:

```sh
flutter run -d chrome --web-port=3000
```

Trong VS Code, chọn cấu hình **steady (Supabase email / Google / Facebook)**.
Xem [hướng dẫn bật email, Google và Facebook](docs/auth-setup.md) và
[quy tắc screening](docs/health-screening.md).
Xem [cách cho máy khác đăng nhập và test](docs/testing-on-other-devices.md) để
chạy qua IP LAN hoặc build bản web độc lập với phiên debug.

## Ngôn ngữ

Mở **Hồ sơ → Ngôn ngữ** để chọn **Tiếng Việt**, **English** hoặc **Theo thiết bị**.
Lựa chọn được lưu trên thiết bị và khôi phục khi mở app. Ngôn ngữ thiết bị không
được hỗ trợ sẽ dùng tiếng Anh. Đổi ngôn ngữ không xoá biểu mẫu hay tạo lại thực đơn.

Các bản dịch nằm trong `lib/l10n/app_en.arb` và `app_vi.arb`. Sửa hai tệp này rồi
chạy `flutter gen-l10n`; không sửa trực tiếp các tệp Dart được sinh tự động.

## Meals

- Kê khai cơ thể/body fat → bệnh lý → dị ứng và sở thích → mục tiêu tập luyện → xem lại và tạo thực đơn.
- Tách mục tiêu, năng lượng, macro và kiểu ăn; có Lean bulk, Aggressive bulk, Keto, Low-carb, Low-fat, ăn chay và các lựa chọn khác.
- Thực đơn bảy ngày, ba/bốn bữa hoặc lịch 16:8; khẩu phần theo mục tiêu calorie và macro ước tính.
- Đổi món kiểm tra lại dinh dưỡng cả ngày cùng dị ứng, thời gian và ngân sách.
- Danh sách mua sắm cộng nguyên liệu cả tuần và cho phép đánh dấu đã mua.
- Có thể chỉnh sửa, huỷ chỉnh sửa hoặc xoá hồ sơ với hộp thoại xác nhận.

Hồ sơ dinh dưỡng, thực đơn và hoạt động hiện giữ trong bộ nhớ, mất khi đóng app.
Lựa chọn ngôn ngữ và phiên Supabase Auth được khôi phục trên thiết bị. Công thức, dinh dưỡng và giá là dữ liệu
mẫu; xem [mô hình dinh dưỡng, nguồn và giới hạn](docs/nutrition-system.md).
Phần thưởng hiện là bản xem trước; nhắc nhở và kết nối dữ liệu sức khoẻ chưa được tích hợp.

## Chạy và kiểm tra

Yêu cầu Flutter tương thích Dart `^3.13.4`.

```sh
flutter pub get
flutter gen-l10n
dart format lib test tool
flutter analyze --no-pub
flutter test --no-pub
flutter run -d chrome --no-pub
```

Trên Windows, plugin lưu ngôn ngữ yêu cầu hỗ trợ symlink: bật **Developer Mode**
trước khi `flutter pub get`. Build app Windows còn yêu cầu Visual Studio với
workload **Desktop development with C++**. Kiểm tra môi trường bằng `flutter doctor -v`.

## Ảnh giao diện

Ảnh do Flutter dựng ở kích thước điện thoại/desktop, dùng dữ liệu mẫu:

- [Thiết lập tiếng Việt](docs/screenshots/meals-vi-setup.png)
- [Thực đơn tiếng Việt](docs/screenshots/meals-vi-plan.png)
- [Các bữa ăn tiếng Anh](docs/screenshots/meals-en-recipes.png)

Tạo lại ảnh (có thể truyền phông TTF để thay phông kiểm thử mặc định):

```sh
flutter test tool/visual_review_test.dart --no-pub --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
```

Xem [kết quả rà soát](docs/app-review.md) để biết phạm vi kiểm tra và các giới hạn môi trường.
