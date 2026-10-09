# Thiết lập đăng nhập Steady

Ưu tiên bật **email/mật khẩu → Google → Facebook**. App dùng Supabase Auth đã
có trong dự án; không cần thêm Firebase hay SDK đăng nhập riêng.

Project hiện dùng: **Steady** (`bgcczipzseddvnwpvkhz`), URL
`https://bgcczipzseddvnwpvkhz.supabase.co`. URL và publishable key công khai nằm
trong `lib/auth/public_auth_config.dart`, đi kèm bản clone/build. Kiểm tra dịch vụ
Auth ngày 8/10/2026: email và đăng ký đã bật, cần xác nhận email; Google/Facebook
chưa bật nên các nút tương ứng tiếp tục bị vô hiệu hoá.
Endpoint đăng nhập mật khẩu đã kiểm tra với tài khoản giả không tồn tại:
publishable key được chấp nhận và trả `invalid_credentials` như dự kiến.
Không tạo tài khoản hay gửi email trong phép kiểm tra này.

Lỗi trước đây: `flutter run` không có dart defines khiến app dùng controller chưa
cấu hình; file cấu hình gitignored không đi theo bản clone. Nay chạy bình thường
hoặc F5 đều dùng project Steady mặc định. Xem [hướng dẫn cho tester](testing-on-other-devices.md).

## 1. Bật email trước

1. Chọn hoặc tạo project Supabase dành cho Steady.
2. Trong **Authentication → Sign In / Providers → Email**, bật email/password.
   Giữ xác nhận email nếu dùng tài khoản thật. Cấu hình SMTP cho môi trường
   production theo [hướng dẫn Supabase](https://supabase.com/docs/guides/auth/auth-smtp).
3. Trong **Authentication → URL Configuration**, đặt Site URL và thêm các URL
   quay lại app:
   - Web phát triển: `http://localhost:3000/`.
   - Web production: URL chính xác nơi triển khai Steady, gồm đường dẫn nếu có.
   - Android/iOS/macOS: `io.steady.app://login-callback/`.
4. **Chỉ khi muốn dùng project khác**, sao chép `supabase-config.example.json` thành `supabase-config.json`. Điền
   `SUPABASE_URL` và `SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_...`) từ project.
   Để hai cờ Google/Facebook là `false` trong bước đầu.

```powershell
flutter run -d chrome --web-port=3000
```

Chỉ sao chép khi chưa có file cấu hình; giữ cấu hình đang dùng nếu file đã tồn tại.
Trong VS Code, chọn **steady (Supabase email / Google / Facebook)** rồi nhấn F5.
Các cấu hình mặc định trong VS Code không yêu cầu file cục bộ. Để đổi project,
truyền `--dart-define-from-file=supabase-config.json` khi run/build và dừng, chạy
lại app. URL/key phải được thay cùng nhau; override thiếu/sai bị từ chối và không
tự quay về project khác. Cờ provider có thể bật qua dart define tương ứng.

Tạo tài khoản bằng email, xác nhận thư nếu được yêu cầu, rồi đăng nhập. Liên kết
xác nhận có thể mở lại app trên thiết bị đăng ký; có thể quay lại và đăng nhập
bằng mật khẩu nếu xác nhận ở thiết bị khác. Mật khẩu mới cần ít nhất 8 ký tự;
chính sách bổ sung của project vẫn do Supabase kiểm tra.

## 2. Bật Google (tài khoản Gmail)

1. Trong Google Cloud, thiết lập OAuth consent screen và tạo OAuth client loại
   **Web application**. Nếu đang ở chế độ testing, thêm tài khoản thử nghiệm.
2. Thêm Authorized redirect URI lấy từ provider Google trong Supabase:
   `https://<PROJECT_REF>.supabase.co/auth/v1/callback`.
3. Bật Google trong Supabase Auth Providers và nhập Client ID/Client Secret.
4. Đặt `AUTH_GOOGLE_ENABLED` thành `true` trong file cấu hình, chạy lại app.

Google đăng nhập qua trình duyệt, không cần `google-services.json` hoặc package
`google_sign_in` cho luồng OAuth này. Xem
[hướng dẫn Google chính thức](https://supabase.com/docs/guides/auth/social-login/auth-google).

## 3. Bật Facebook

1. Tạo ứng dụng Meta có Facebook Login, thiết lập các thông tin được Meta yêu cầu.
2. Thêm Valid OAuth Redirect URI từ Supabase:
   `https://<PROJECT_REF>.supabase.co/auth/v1/callback`.
3. Bật Facebook trong Supabase Auth Providers và nhập App ID/App Secret.
4. Khi ứng dụng Meta ở chế độ development, dùng tài khoản có vai trò/tester phù hợp.
   Hoàn tất yêu cầu của Meta trước khi mở cho người dùng công khai.
5. Đặt `AUTH_FACEBOOK_ENABLED` thành `true`, chạy lại app.

Xem [hướng dẫn Facebook chính thức](https://supabase.com/docs/guides/auth/social-login/auth-facebook).

Client Secret/App Secret chỉ nhập ở dashboard Supabase, không đưa vào Flutter,
file JSON hay Git. `supabase-config.json` đã được gitignore; ứng dụng chỉ nhận
publishable key, không nhận service-role/secret key. Publishable key vốn được
phân phối trong client; URL/key mặc định được theo dõi trong Git để bản clone
hoạt động. Xem [tài liệu API keys](https://supabase.com/docs/guides/api/api-keys).

## Callback và phạm vi hỗ trợ

Android, iOS và macOS đã đăng ký scheme `io.steady.app`. Supabase Flutter dùng
PKCE và xử lý callback, lưu/khôi phục phiên đăng nhập. Web quay lại URL đang chạy
app, bỏ query/fragment của lần xác thực trước. URL này phải có trong allowlist.
URL callback của Google/Meta **đi tới Supabase**; URL quay về Steady **đặt trong
Supabase URL Configuration**. Đây là hai cấu hình riêng.

Windows/Linux vẫn dùng được email; các nút mạng xã hội bị tắt vì dự án chưa đăng
ký callback cho hai nền tảng này. Xem
[tài liệu deep link](https://supabase.com/docs/guides/auth/native-mobile-deep-linking?platform=flutter).

Mở trình duyệt chưa tạo phiên đăng nhập. Chỉ sau khi callback trả về phiên được
Supabase xác thực, app đóng route đăng nhập và giữ tab hiện tại với tài khoản đã
đăng nhập. MVP không có đường vào screening; tab Món ăn / Recipes mở danh mục
công thức. Đóng trình duyệt hoặc huỷ màn hình đăng nhập vẫn
tiếp tục dùng app với tư cách khách. Provider chưa bật sẽ có nút bị vô hiệu
hoá; cờ cấu hình không tự bật provider trên dashboard.

Nếu thiếu/sai cấu hình, app ghi rõ chưa kết nối dịch vụ đăng nhập. Nếu khởi tạo
dịch vụ thất bại, Home và check-in vẫn dùng SQLite trên Android/iOS. Danh mục
công thức dùng được cho khách và tài khoản. Planner/screening chỉ còn trong mã
và harness nghiên cứu, vẫn giữ các quy tắc của chúng. Đăng nhập mới cần internet;
phiên cũ có thể được khôi phục
và báo lỗi khi không làm mới được token. Khôi phục mật khẩu chưa nằm trong luồng này.

## Kiểm thử

```sh
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub
```

Test dùng SDK Supabase thật với HTTP fixture và browser launcher giả lập để kiểm
tra email, signup callback, PKCE, Google/Facebook, lỗi mở trình duyệt, và việc
không vào app khi chỉ mới mở OAuth. Widget test kiểm tra validation, email xác
nhận, thông báo lỗi, screening, và hai ngôn ngữ trên màn hình hẹp/phông lớn.
Đăng nhập end-to-end với provider thật cần project và OAuth credentials đã bật.

Đã kiểm tra ngày 7/10/2026: 47 unit/widget test pass; static analysis không báo lỗi;
bản build web thành công. Ảnh đăng nhập tiếng Việt/Anh được dựng bằng phiên giả lập
và kiểm tra trực quan. Chưa thử đăng nhập trên project thật hoặc thiết bị Android/iOS.

Kiểm tra bổ sung ngày 08/10/2026: 80 test pass, analyze sạch và build web thành
công với cấu hình mặc định. SDK thật kết nối Auth của project Steady, nhận đúng
`invalid_credentials` khi gửi thông tin giả; chưa dùng mật khẩu của người dùng để
kiểm tra đăng nhập tài khoản thật. Xem [hướng dẫn test trên máy khác](testing-on-other-devices.md).
