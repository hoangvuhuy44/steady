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

- **Thực đơn cá nhân** có questionnaire 5 bước, lưu hồ sơ, ba bữa mỗi ngày,
  đổi món và phản hồi. Khách lưu riêng trên thiết bị; tài khoản dùng Supabase
  với RLS và revision chống ghi đè. Xem [triển khai và giới hạn dữ liệu](docs/personalized-daily-menu.md).
  Cần áp dụng migration mới để dùng lưu trữ tài khoản. Kho hiện có chưa đủ
  dữ liệu xác minh để gợi ý cho người có dị ứng hoặc chế độ kiêng bắt buộc.
- Nhật ký lưu bằng SQLite trên thiết bị, tách khách và từng tài khoản. Home tính
  chỉ số từ nhật ký thật. Đăng nhập không gộp hoặc xoá nhật ký khách.
- Tab **Món ăn / Recipes** dùng kho `meals` hiện có; sau thiết lập hiển thị
  thực đơn Sáng/Trưa/Tối. Kho công thức tham khảo vẫn có trang chi tiết nguyên
  liệu, định lượng và cách nấu riêng.
- Kết hợp lọc loại bữa, thời gian tối đa, nhãn dị ứng và nguyên liệu muốn tránh.
  Khi rỗng vẫn giữ bộ lọc; người dùng tự đổi lựa chọn hoặc xoá bộ lọc.
- Bộ lọc kho tham khảo chỉ đối chiếu nhãn công thức và giải thích giới hạn.
  Thực đơn cá nhân dùng bộ lọc bắt buộc riêng, đối chiếu cây thành phần và chặn
  dữ liệu chưa xác minh. Không xác nhận an toàn dị ứng hay kiểm tra nhiễm chéo.
- Định lượng là công thức mẫu, không phải khuyến nghị khẩu phần cá nhân.
- Thực đơn cá nhân hiển thị chi phí ước tính mẫu, ngân sách và thời gian ưu tiên;
  dinh dưỡng chỉ hiển thị khi có nguồn đáng tin cậy. Không thu thập cơ thể/bệnh
  nền, không mở lại Keto/bulk/16:8 hay planner nghiên cứu.

Xem [phạm vi sản phẩm](docs/product-scope.md) và [lưu nhật ký](docs/activity-storage.md).
Nhắc tập Android/iOS dùng Supabase + FCM đã có code MVP, cần cấu hình backend
và Firebase để nhận push thật. Xem [thiết lập và checklist nhắc tập](docs/workout-reminders.md)
và [báo cáo kiểm chứng](docs/WORKOUT_REMINDERS_REPORT.md).
Screening sức khỏe nghiên cứu, đồng bộ nhật ký server và đổi thưởng chưa được tích hợp.

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
