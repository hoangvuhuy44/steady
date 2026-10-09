# Phạm vi sản phẩm Steady MVP

Cập nhật 09/10/2026. Nền tảng ưu tiên: Android và iOS.

## Trong MVP

Home mở mặc định, tính chỉ số từ lịch sử hoạt động thật. Nhật ký, chế độ khách,
điểm và lịch sử của từng tài khoản giữ cơ chế SQLite hiện có; chưa đồng bộ server.
Đăng nhập là tuỳ chọn ở Hồ sơ. Đăng nhập hoặc đổi tài khoản giữ tab hiện tại,
đóng route của phiên trước và chuyển vùng nhật ký, không mở screening.

**Món ăn / Recipes** là danh mục **Gợi ý món ăn / Recipe ideas**:

- Dùng mọi công thức trong kho `meals`, giữ định lượng gốc, không scale theo người.
- Thẻ món: tên đã dịch, loại bữa, thời gian nấu ước tính. Chi tiết: nguyên liệu,
  định lượng và cách nấu; ghi rõ công thức mẫu, không phải khẩu phần cá nhân.
- Lọc loại bữa (sáng/trưa/tối/bữa phụ), thời gian tối đa, nhãn dị ứng và nguyên liệu
  muốn tránh. Các nhóm kết hợp bằng AND; loại mọi nhãn/nguyên liệu đã chọn.
  Thời gian bằng giới hạn vẫn được chấp nhận.
- Khi rỗng, giữ tất cả lựa chọn, giải thích và nút xoá bộ lọc. Chỉ thao tác người
  dùng mới đổi bộ lọc; không tự nới hoặc đưa món vi phạm vào kết quả.
- Dị ứng đối chiếu `Meal.contains`; nguyên liệu muốn tránh đối chiếu chính xác
  khoá nguyên liệu. Không suy luận nhãn từ nguyên liệu, không chứng nhận an toàn
  với dị ứng. Giới hạn nhãn, thay thế nguyên liệu, sốt và nhiễm chéo được giải
  thích ngay trong bộ lọc trước các lựa chọn nhãn.
- Khách và tài khoản có cùng quyền xem; screening cũ không mở khoá/chặn danh mục.
  Bộ lọc chỉ ở bộ nhớ UI, giữ khi đổi tab/ngôn ngữ, reset khi mở lại app/chuyển phiên.
- Bố cục cuộn dọc, chip xuống dòng; ưu tiên điện thoại và chữ lớn.

## Ngoài giao diện MVP

Ẩn giá, ngân sách, calorie, protein, fibre, macro, tổng dinh dưỡng và mua sắm tuần.
Không có kê khai tuổi, chiều cao, cân nặng, body fat, bệnh nền/thuốc; không có
Keto, bulk, 16:8, sinh thực đơn cá nhân, scale khẩu phần hay đổi món trong thực đơn.
ID một số món có nguồn từ thử nghiệm planner nhưng UI chỉ hiển thị tên món và cách nấu.

`RecipesScreen`, `RecipeDetailScreen` chỉ đọc công thức và `RecipeFilter`; không
gọi `NutritionTargets.estimate`, `MealPlanner.generate`, getter kế hoạch hoặc
các hàm thay đổi screening của store.

## Nghiên cứu được giữ lại

`lib/nutrition`, `lib/screening`, `ScreeningScreen` và
`lib/research/research_meals_screen.dart` giữ các quy tắc sức khoẻ và planner.
Store vẫn chặn tạo/đổi thực đơn khi thiếu screening phù hợp. Màn hình nghiên cứu
không được import/định tuyến từ `SteadyApp`; harness chỉ nằm trong test/tool.
Unit tests planner/targets/strategy/screening và widget tests screening, khẩu phần,
đổi món, checklist, chỉnh sửa/xoá tiếp tục chạy để nghiên cứu sau MVP.

## Kiểm chứng

Chạy trên Windows ngày 09/10/2026: `flutter gen-l10n` thành công;
`flutter analyze` báo **No issues found**; `flutter test` có **125 tests passed**.
Lệnh dựng ảnh riêng `flutter test tool/visual_review_test.dart` cũng thành công.

`recipe_filter_test.dart`: dữ liệu gốc, AND, ranh giới thời gian, kết quả rỗng,
giới hạn lọc theo nhãn. `recipes_widget_test.dart`: danh mục/chi tiết, bộ lọc,
reset thủ công, khách, đăng nhập không chuyển tab, đổi ngôn ngữ, màn hình 320 px
với chữ 200% trên theme Android/iOS. `widget_test.dart` kiểm tra cả năm tab ở
360 px chữ 160%. Kiểm thử nhật ký, Home và Auth hiện có tiếp tục chạy.

Widget tests với theme nền tảng không thay thế thiết bị. Trước phát hành cần chạy
APK Android và build/run iOS trên macOS/Xcode, kiểm tra SQLite, bàn phím, safe area
và callback Auth thật. Không suy ra các kiểm chứng này chỉ từ analyze/test trên Windows.

Đã dựng 12 ảnh danh mục/bộ lọc/chi tiết Việt/Anh ở 390×844 px, chữ 100% và 200%
bằng `tool/visual_review_test.dart`; ảnh có tiền tố `recipes-` trong
`docs/screenshots`. Rà soát trực quan các ảnh danh mục, chi tiết và bộ lọc chữ lớn
tiếng Việt cho thấy nội dung xuống dòng và cuộn được, định lượng mẫu hiển thị rõ.

Lần chạy đầu phát hiện repository thiếu `guestOwnerId()` dù store và kiểm thử
khách đã gọi hàm này. Đã bổ sung định danh khách bền vững, migration v1→v2 giữ
nhật ký tài khoản và đọc cả timestamp cũ/mới theo thứ tự thời gian. Các kiểm thử
SQLite FFI xác nhận mở lại file, tách khách/tài khoản và migration; không sửa các
quy tắc Home hoặc planner/screening để làm test qua.
