# Steady

## Android APK testing

See [Android installation and device testing](docs/ANDROID_APK_TESTING.md) and
[the APK build report](docs/ANDROID_APK_BUILD_REPORT.md). Test APKs are delivered
in the ignored `dist/` directory. Keep the same application ID and signing key
when installing updates to preserve the local activity journal.

Ứng dụng Flutter ghi nhật ký vận động và **Gợi ý món ăn**, ưu tiên Android và iOS.
Giao diện hỗ trợ tiếng Việt và tiếng Anh, gồm công thức, nguyên liệu và cách nấu.
Home là màn hình mặc định; đăng nhập không tự chuyển tab hay mở khai báo sức khoẻ.

## Phạm vi MVP

- Nhật ký lưu bằng SQLite trên thiết bị, tách khách và từng tài khoản. Home tính
  chỉ số từ nhật ký thật. Đăng nhập không gộp hoặc xoá nhật ký khách.
- Tab **Món ăn / Recipes** dùng kho `meals` hiện có. Mỗi món có loại bữa, thời
  gian nấu ước tính và trang chi tiết nguyên liệu, định lượng, cách nấu.
- Kết hợp lọc loại bữa, thời gian tối đa, nhãn dị ứng và nguyên liệu muốn tránh.
  Khi rỗng vẫn giữ bộ lọc; người dùng tự đổi lựa chọn hoặc xoá bộ lọc.
- Dị ứng chỉ đối chiếu nhãn công thức, có giải thích giới hạn ngay trong phần
  lọc. Kết quả không xác nhận an toàn với dị ứng, không kiểm tra nhiễm chéo.
- Định lượng là công thức mẫu, không phải khuyến nghị khẩu phần cá nhân.
- UI MVP ẩn giá, ngân sách, calorie, macro, tổng dinh dưỡng và toàn bộ kê khai
  cơ thể/bệnh nền, Keto/bulk/16:8, sinh thực đơn cá nhân.

Xem [phạm vi sản phẩm](docs/product-scope.md) và [lưu nhật ký](docs/activity-storage.md).
Nhắc nhở, dữ liệu sức khoẻ, đồng bộ server và đổi thưởng chưa được tích hợp.

## Đăng nhập tuỳ chọn

Khách dùng được Home, nhật ký và công thức. Đăng nhập từ **Hồ sơ** dùng Supabase
Auth (email/mật khẩu, Google, Facebook theo cấu hình provider). Cấu hình công
khai của Steady có sẵn trong app; không cần tệp JSON cục bộ.
Xem [thiết lập Auth](docs/auth-setup.md) và [test máy khác](docs/testing-on-other-devices.md).

## Ngôn ngữ

Mở **Hồ sơ → Ngôn ngữ**: **Tiếng Việt**, **English** hoặc **Theo thiết bị**.
Lựa chọn lưu trên thiết bị; ngôn ngữ chưa hỗ trợ dùng tiếng Anh. Đổi ngôn ngữ
giữ bộ lọc công thức. Bản dịch ở `lib/l10n/app_en.arb` và `app_vi.arb`; sửa hai
tệp rồi chạy `flutter gen-l10n`, không sửa các tệp Dart được sinh tự động.

## Nghiên cứu được giữ lại

Planner, targets và screening giữ các quy tắc và kiểm thử. Màn hình cũ nằm ở
`lib/research/research_meals_screen.dart`, chỉ mở bằng harness test/tool, không
có route từ MVP. Danh mục mới không gọi `NutritionTargets.estimate` hoặc
`MealPlanner.generate`. Xem [planner](docs/meal-planner.md),
[screening](docs/health-screening.md) và [dinh dưỡng](docs/nutrition-system.md).

## Chạy và kiểm tra

Yêu cầu Flutter tương thích Dart `^3.13.4`.

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter devices
flutter run -d <android-device-id>
```

iOS cần macOS và Xcode. Windows chạy widget/unit tests và Android khi có
SDK/thiết bị phù hợp. Bật **Developer Mode** nếu plugin yêu cầu symlink;
kiểm tra môi trường bằng `flutter doctor -v`.

Web dùng xem thử, chưa là nền tảng lưu nhật ký MVP:

```sh
flutter run -d chrome --web-port=3000
```

Tạo ảnh danh mục/bộ lọc/chi tiết và chữ lớn từ Flutter:

```sh
flutter test tool/visual_review_test.dart --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
```

Ảnh Meals/screening cũ ở `docs/screenshots` là tư liệu nghiên cứu, không đại diện
MVP hiện tại. [Rà soát app](docs/app-review.md) ghi các kiểm tra lịch sử.
