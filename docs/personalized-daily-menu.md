# Thực đơn cá nhân hằng ngày

Triển khai ngày 22/10/2026. Tính năng mới độc lập với planner/screening nghiên cứu.
Không thêm SDK, dịch vụ AI, hay dependency ứng dụng.

## Kiến trúc đã kiểm tra

- `SteadyApp` quản lý phiên Supabase Auth, tab và vòng đời ứng dụng.
- Onboarding sức khỏe cũ và `MealPlanner` chỉ dành cho nghiên cứu, không có route
  trong MVP. Không mở lại luồng thu thập tuổi, cân nặng, bệnh sử này.
- `meals` trong `lib/nutrition/meal_planner.dart` là nguồn công thức hiện có;
  `RecipesScreen`/`RecipeDetailScreen` có sẵn tên, nguyên liệu và cách nấu Việt/Anh.
- Nhật ký tiếp tục dùng repository SQLite/SharedPreferences hiện có, tách khách
  và tài khoản. Auth và nhắc tập tiếp tục dùng Supabase; thay đổi nhắc tập trong
  workspace được giữ nguyên. Không có AGENTS.md áp dụng trong cây thư mục đã kiểm tra.

## Sử dụng

Mở **Món ăn → Thực đơn cá nhân** hoặc **Hồ sơ → Hồ sơ ăn uống và thực đơn**.
Questionnaire có 5 bước: dị ứng/không dung nạp; chế độ ăn/mục tiêu; khẩu vị;
ngân sách VND/thời gian/múi giờ; giới hạn do chuyên gia chỉ định. Sau khi lưu,
tab Món ăn hiển thị đúng ba vị trí Sáng, Trưa, Tối. Kho công thức tham khảo vẫn
có đường dẫn riêng, không phải danh sách món được cá nhân hóa.

Dị ứng chọn nhiều, có “Không có”, có nhập thêm; “Không có” loại trừ các lựa chọn
dị ứng còn lại nhưng không xóa không dung nạp. Không thu thập số đo cơ thể,
bệnh sử hay thuốc. Nguyên liệu yêu thích/không thích và hạn mức có thể để trống.
Hồ sơ được chỉnh qua nút **Chỉnh hồ sơ ăn uống**. Chỉnh sở thích mềm áp dụng khi
chọn/đổi món tiếp theo; các món còn hợp lệ trong ngày được giữ để tránh tự đổi.

Giới hạn bắt buộc gồm dị ứng, không dung nạp, chế độ ăn và nguyên liệu phải tránh
theo chỉ định. Chỉ định khác bằng văn bản được lưu nguyên văn và **chặn gợi ý**;
không chẩn đoán, trích xuất liều, hay suy ra chế độ điều trị từ văn bản.

## Dữ liệu và điều kiện kiểm tra

`FoodRecipe` bổ sung cây `FoodComponent` gồm cả sốt, nước dùng, gia vị, nhãn
dị ứng, trạng thái thông tin, loại bữa qua công thức gốc, chế độ ăn, khẩu phần,
thời gian, chi phí, ảnh tùy chọn và dinh dưỡng có nguồn. Mọi nhánh phụ đều phải
được kê khai và xác minh trước khi một công thức được coi là có thể đối chiếu.

`FoodNames` chuẩn hóa tên Việt/Anh và các tên đồng nghĩa như lạc/đậu phộng,
đậu phụ/đậu hũ, mè/vừng, xì dầu/nước tương. Không dò dị ứng bằng tên món.
Từ chưa nhận diện được giữ lại; nếu là điều kiện bắt buộc, nó chặn kết quả,
không tự xem như không có dị ứng. Nhóm nguyên liệu được đối chiếu bảo thủ;
ví dụ yến mạch không được tự coi là không chứa gluten.

**Kho hiện có đều là dữ liệu mẫu, thành phần chưa được xác minh đầy đủ.** Có
công thức ghi “gia vị/nước chấm tính riêng”, một số món còn có nguyên liệu trong
phần hướng dẫn nhưng chưa nằm trong bảng thành phần. Không điền đoán các
thành phần này. Adapter đánh dấu toàn bộ kho là `unverified`, không cấp nhãn
chay/thuần chay đã xác minh và không dùng các macro/calorie thử nghiệm cũ.
Vì vậy, hiện chỉ hồ sơ không có giới hạn bắt buộc mới nhận món mẫu; hồ sơ có
dị ứng, không dung nạp, kiêng chay/thuần chay hoặc giới hạn nguyên liệu sẽ nhận
ba thẻ trống và giải thích rõ. Đây là giới hạn dữ liệu thực tế, không phải lỗi
cần khắc phục bằng việc bỏ bộ lọc.

Để đưa công thức vào nguồn sử dụng thật, cập nhật `food_catalog.dart`: kiểm tra
đầy đủ cả thành phần phụ và công thức nhà sản xuất, khai báo nhãn dị ứng cho
từng thành phần, trạng thái `complete` và `verified` trên toàn bộ cây, chế độ
ăn có căn cứ, khẩu phần và nguồn dinh dưỡng đã rà soát. Không thay thành phần
mà vẫn giữ kết quả xác minh cũ. Tập dữ liệu cho kiểm thử có nhãn verified chỉ là
fixture, không được đưa vào app làm dữ liệu thật.

Thông tin thành phần **không bảo đảm không nhiễm chéo**. UI luôn nhắc kiểm tra
nhãn và nơi chế biến. Không có cơ chế kiểm tra dị ứng bằng LLM.

## Chọn món, lưu và đổi món

`DailyMenuEngine.eligible` chạy điều kiện bắt buộc trước `rank`/`generate`.
Xếp hạng xét khẩu vị, thời gian, lịch sử hai ngày gần nhất, mục tiêu khi có
dinh dưỡng đáng tin cậy và tổng chi phí của cả ngày. Ngân sách/thời gian là
ưu tiên mềm đã giải thích trong form; UI ghi rõ khi vượt. Điều kiện bắt buộc
không bao giờ được nới khi thiếu ứng viên.

Chọn đúng ba slot, mỗi slot tối đa một món. Không thêm bữa phụ, không scale
khẩu phần theo người. Đổi món giữ nguyên hai slot còn lại, loại món hiện tại
khỏi pool thay thế rồi kiểm tra lại toàn bộ điều kiện. Không có món thay thế:
giữ món cũ và báo rõ; “Không thích món này” lưu ID bị từ chối và có thể để slot
trống nếu không còn món phù hợp. Phản hồi này mạnh hơn sở thích nguyên liệu.

Thực đơn được lưu theo khóa múi giờ/ngày địa phương, không random khi tải lại.
Chế độ “Theo thiết bị” ghi nhận tên múi giờ và độ lệch thực tế, dùng chuyển đổi
giờ mùa hè của hệ điều hành. Người dùng có thể chọn độ lệch UTC cố định theo
bước 15 phút; đây không phải múi giờ IANA tự đổi DST. Nếu cần giữ cùng múi giờ
trên nhiều thiết bị khác nhau, chọn cùng độ lệch UTC. Bộ hẹn giờ đổi ngày dùng
múi giờ đã chọn; resume tải lại hồ sơ và thực đơn từ repository.

Mỗi lần đọc/hiển thị và mỗi lần sửa hồ sơ đều kiểm tra lại món đã lưu. Món không
còn hợp lệ bị gỡ và chỉ thay bằng ứng viên qua bộ lọc. Ngay cả khi catalogue
thay đổi qua bản cập nhật app, kết quả cũ không được hiển thị mà không kiểm tra.
Thiếu dữ liệu/kết nối/xung đột: ẩn kết quả cũ, báo lỗi và có nút tải lại.
Lưu tối đa 35 khóa ngày/múi giờ gần nhất; không giữ lịch sử vô hạn.

Dinh dưỡng chỉ hiển thị khi có `FoodNutrition` hợp lệ cùng nguồn; tổng ngày
chỉ tính khi đủ ba bữa có dữ liệu. Không tính nhu cầu năng lượng cá nhân,
không khẳng định đạt mục tiêu. Mục tiêu giảm cân/tăng cơ chỉ tác động xếp hạng
trên dữ liệu đủ tin cậy, không tạo chế độ điều trị.

## API và migration

`MenuRepository`: khách dùng SharedPreferences riêng (`steady.guest.food.v1`);
tài khoản dùng Supabase Data API, không ghi hồ sơ tài khoản vào cache khách.
Không gộp dữ liệu khi đăng nhập. Chuyển phiên hủy controller cũ và đóng route.
Read/write cũ hoàn tất muộn không cập nhật màn hình phiên mới.

Migration `supabase/migrations/20261022090114_food_personalization.sql` chỉ thêm:

- Bảng `public.food_personalization`: một document JSONB/hồ sơ, các menu và phản
  hồi theo `auth.users.id`; giới hạn 128 KiB, version schema và revision.
- RLS SELECT/INSERT/UPDATE theo `auth.uid() = user_id`, gồm `WITH CHECK` khi sửa.
  Không cấp quyền anon hoặc xóa trực tiếp cho client.
- RPC `food_personalization_save(document, expected_revision, expected_owner)` dùng
  `SECURITY INVOKER`, lấy owner từ Auth. Lưu profile/menu/phản hồi trong cùng
  transaction; revision không khớp trả SQLSTATE `40001` để tránh ghi đè giữa
  các thiết bị. `expected_owner` chỉ dùng kiểm tra trùng danh tính phiên dự kiến
  với `auth.uid()`, chặn request gửi dở khi SDK đổi token sang tài khoản khác;
  không dùng tham số này để cấp quyền hoặc chọn owner ghi dữ liệu.

Đọc: `from('food_personalization').select('revision,data').eq('user_id', owner)`.
Ghi: `rpc('food_personalization_save', params: {...})`. Server RLS kiểm tra lại
quyền độc lập với bộ lọc phía Flutter. Đây là dữ liệu riêng từng người, không
phải API chứng nhận an toàn hay API kê đơn. Client đã chỉnh sửa có thể sửa dữ
liệu của chính tài khoản đó, không thể đọc/sửa dữ liệu tài khoản khác.

**Migration chưa được áp dụng lên Supabase đang chạy.** Cần áp dụng file SQL
trên đúng project Steady hoặc đưa vào quy trình deploy migration hiện có. Chưa
có kiểm chứng đăng nhập/REST với database thật sau migration. Không dùng
`db reset` trên dữ liệu thật và không tự triển khai toàn bộ migration nhắc tập
chưa liên quan nếu chưa kiểm tra trạng thái project. Bản khách dùng được ngay;
bản tài khoản báo lỗi cấu hình nếu bảng/RPC chưa được triển khai.

Quyền RLS và cách gọi upsert/RPC đã đối chiếu với tài liệu chính thức:
[Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security),
[Flutter database API](https://supabase.com/docs/reference/dart/upsert).

## Kiểm tra

```powershell
flutter analyze
flutter test
# Trong thư mục supabase:
deno task test
```

`test/daily_menu_test.dart`: dị ứng trong sốt/nước dùng lồng nhau, tên đồng nghĩa,
thiếu dữ liệu, thành phần phụ chưa xác minh, chế độ kiêng, giới hạn y tế, sở
thích mềm, thiếu món, tổng giá, tổng dinh dưỡng, đổi một bữa, phản hồi, tải lại,
đổi hồ sơ, đổi ngày/múi giờ, lỗi ghi/đọc và xung đột nhiều controller.
`test/daily_menu_widget_test.dart`: questionnaire, validation, ba thẻ, đổi món,
chỉnh dị ứng, chữ 200%/320 px Việt/Anh và đóng route khi đổi phiên.
`supabase/tests/food_personalization_test.ts`: PostgreSQL qua PGlite đã có trong
repository; quyền anon, tách hai user, ngăn đổi owner, transaction/revision,
document lỗi. Không thay thế kiểm tra Data API/RLS trên Supabase thật.

Cần bổ sung kho công thức đã rà soát, kiểm chứng nguồn dinh dưỡng/chi phí,
deploy migration và chạy thử Android/iOS với Auth thật trước khi phát hành.

Kết quả trên workspace ngày 22/10/2026: `flutter analyze --no-pub` không có lỗi;
`flutter test` có **158 passed, 1 skipped**; backend `deno task test` có
**5 passed, 11 steps, 0 failed**. Các bài mới bao gồm 12 kiểm thử logic và 3
kiểm thử widget. `git diff --check` thành công. Chưa chạy trên thiết bị thật.
