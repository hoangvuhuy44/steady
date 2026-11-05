# D02 — Navigation beta

Người dùng cho phép triển khai riêng D02 ngày 05/11/2026. PR này phụ thuộc PR0
`fd5b777`, không chấp thuận D01/D03–D13 hoặc mở gate Commitment/Recovery.

Navigation chính còn Today/Home, Check-in, Profile. Meals/Recipes và Rewards nằm
trong card phụ ở Profile, dùng nhãn VI/EN và theme hiện có. Meals vẫn mở daily menu
nếu đã lưu food profile, hoặc catalogue nếu chưa có profile. Lối vào food preferences
hiện hữu được giữ. Research không thêm route từ app.

Các màn hình dùng cùng store/controller và giữ mounted state trong IndexedStack,
vì vậy chuyển qua Profile rồi đổi ngôn ngữ không làm mất bộ lọc công thức. Khi ở
mục phụ, navigation đánh dấu Profile; Back trên thanh tiêu đề hoặc Android system
Back về Profile. Đổi tài khoản/đăng xuất đóng mục phụ và route của phiên cũ.

Không thay repository, dữ liệu v2, food persistence, auth provider, reminder logic,
schema hoặc dependencies. Rollback bằng revert commit D02, không cần data migration.

## Kiểm chứng

Các widget tests được cập nhật theo lối vào Profile; vẫn kiểm tra recipe filters,
saved daily menu, account switch, auth và guest journal. Kiểm tra ba destination,
Meals/Rewards qua mục phụ, system Back và màn hình VI/EN chữ lớn. Kết quả cuối và
ảnh review được ghi trong mô tả PR.

- `flutter analyze --no-pub`: No issues found.
- `flutter test --no-pub --reporter expanded`: 172 passed, 1 skipped (browser-only).
- Sau chỉnh thanh tiêu đề của daily menu, chạy lại `test/widget_test.dart`,
  `test/daily_menu_widget_test.dart` và `tool/brand_visual_review_test.dart`: 13 passed.
- `flutter build apk --debug --no-pub`: build thành công. Chưa cài/chạy thiết bị thật.
- Không chạy migration hoặc gọi backend production để thử nghiệm.

Ảnh review: [Profile VI](../screenshots/brand/vi-profile-shortcuts.png),
[Meals EN](../screenshots/brand/en-meals.png),
[Rewards EN](../screenshots/brand/en-rewards.png). Harness chụp cả VI/EN với font
bundled; đã rà trực quan navigation, shortcuts và các màn hình phụ.
