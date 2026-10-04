# Steady

Ứng dụng Flutter ghi nhận vận động và lập thực đơn mẫu với món Việt. Giao diện
hỗ trợ đầy đủ tiếng Anh và tiếng Việt, gồm cả công thức, nguyên liệu và thông báo.

## Ngôn ngữ

Mở **Hồ sơ → Ngôn ngữ** để chọn **Tiếng Việt**, **English** hoặc **Theo thiết bị**.
Lựa chọn được lưu trên thiết bị và khôi phục khi mở app. Ngôn ngữ thiết bị không
được hỗ trợ sẽ dùng tiếng Anh. Đổi ngôn ngữ không xoá biểu mẫu hay tạo lại thực đơn.

Các bản dịch nằm trong `lib/l10n/app_en.arb` và `app_vi.arb`. Sửa hai tệp này rồi
chạy `flutter gen-l10n`; không sửa trực tiếp các tệp Dart được sinh tự động.

## Meals

- Thiết lập qua ba bước: thông tin cơ thể, sức khoẻ, thói quen ăn uống.
- Thực đơn bảy ngày, ba bữa/ngày; xem chi phí và dinh dưỡng ước tính theo ngày.
- Đổi món vẫn giữ giới hạn dị ứng, chế độ ăn, thời gian và tổng ngân sách ngày.
- Danh sách mua sắm cộng nguyên liệu cả tuần và cho phép đánh dấu đã mua.
- Có thể chỉnh sửa, huỷ chỉnh sửa hoặc xoá hồ sơ với hộp thoại xác nhận.

Hồ sơ dinh dưỡng, thực đơn và hoạt động hiện giữ trong bộ nhớ, mất khi đóng app.
Chỉ lựa chọn ngôn ngữ được lưu lâu dài. Công thức, dinh dưỡng và giá là dữ liệu
mẫu; xem [chi tiết và giới hạn](docs/meal-planner.md).
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
