# Đăng nhập và test Steady trên máy khác

## Nguyên nhân và bản sửa ngày 08/10/2026

- Trước đây `main.dart` chỉ lấy URL/key từ dart defines. `flutter run` không có cờ cấu hình hiện màn hình login nhưng nút bị khóa. File JSON gitignored không có trên bản clone mới.
- Nay `AuthConfiguration` mặc định dùng cấu hình công khai của project Steady. Chạy từ terminal, VS Code hoặc bản build đều nhận cùng project, không cần chép file cục bộ. Override project khác phải có đủ URL/key; secret key bị từ chối.
- `127.0.0.1` là chính thiết bị đang mở trình duyệt. Máy B mở địa chỉ đó không thể truy cập server trên máy A. Server chỉ chạy khi tiến trình còn hoạt động; localhost không phải một website đã được triển khai.
- App phân biệt lỗi mạng/dịch vụ, cấu hình key, sai thông tin đăng nhập và email chưa xác nhận. Từ bản sửa 09/10/2026, Home/check-in dùng được với tư cách khách; đăng nhập là lựa chọn trong Hồ sơ. Xem [lưu nhật ký và kiểm thử trên thiết bị](activity-storage.md).

## Máy khác tự chạy source

Cài Flutter tương thích Dart `^3.13.4`, lấy bản source mới rồi chạy trong thư mục project:

```sh
flutter pub get
flutter run -d chrome --web-port=3000
```

Lệnh `flutter run` thông thường cũng nhận cấu hình Supabase mặc định. Đăng nhập
bằng email/mật khẩu trong **Supabase → Authentication → Users** của project
Steady. Tài khoản đăng nhập dashboard Supabase và tài khoản người dùng app là
hai loại khác nhau. Profile trong một bảng database không tự tạo danh tính Auth.

Email cần được xác nhận theo chính sách của project. Không đổi mật khẩu, tắt xác
nhận email hay tạo tài khoản thay cho người dùng trong bản sửa này. Google và
Facebook hiện chưa bật ở project; dùng email/mật khẩu để test.

## Nhiều máy dùng chung một server qua LAN

Trên máy host có thể chạy trực tiếp:

```sh
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=3000
```

Giữ terminal mở. Trên máy host mở `http://127.0.0.1:3000/`. Trên máy khác cùng
Wi-Fi/LAN mở `http://<IPv4-của-máy-host>:3000/`; lấy IPv4 bằng `ipconfig`.
Không mở `http://0.0.0.0:3000/` trong trình duyệt.

Để dùng bản release độc lập với phiên debug:

```sh
flutter build web --release
dart run tool/serve_web.dart --host=0.0.0.0 --port=3000
```

Server chỉ phục vụ `build/web`, không phục vụ source, file cấu hình cục bộ hay
các thư mục bên ngoài. Có kiểm tra đường dẫn, loại MIME cho JavaScript/Wasm và
không giữ cache bản cũ.

Trên Windows có thể khởi chạy nền, không phụ thuộc cửa sổ IDE:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\tool\start-test-server.ps1
# Dùng bản build đã có:
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\tool\start-test-server.ps1 -SkipBuild
```

`RemoteSigned` chỉ áp dụng cho tiến trình PowerShell này để chạy script cục bộ,
không sửa chính sách thực thi của Windows. Script in URL host/LAN, PID để dừng và ghi log ở
`build/test-server.stdout.log` / `build/test-server.stderr.log`. Script báo lỗi
nếu cổng đang dùng, không tự tắt một tiến trình khác. Sau khi sửa code phải build
lại; static server không hot reload. Tắt máy hoặc dừng tiến trình sẽ đóng URL.

Nếu máy khác không truy cập được, kiểm tra cùng mạng, không bị Wi-Fi guest/client
isolation và firewall TCP 3000. Ví dụ rule chỉ cho subnet nội bộ, chạy PowerShell
Administrator nếu host thực sự cần mở firewall:

```powershell
New-NetFirewallRule -DisplayName 'Steady LAN test TCP 3000' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3000 -RemoteAddress LocalSubnet -Profile Private,Public
```

Rule trên áp dụng cho Private/Public nhưng chỉ nhận kết nối từ subnet nội bộ.
Máy host hiện dùng Wi-Fi có profile Public, nên rule chỉ dành cho Private sẽ không
áp dụng. Chỉ thêm rule khi đang ở mạng tin cậy; không cần đổi profile toàn mạng.
Windows hiện từ chối quyền kiểm tra firewall của phiên làm việc này, nên chưa xác
nhận được truy cập từ một máy khác. Có thể gỡ rule sau khi test bằng PowerShell
Administrator: `Remove-NetFirewallRule -DisplayName 'Steady LAN test TCP 3000'`.
Không cần mở router/port-forward
để test LAN. Máy ở mạng khác cần một host HTTPS có thể truy cập công khai; IP LAN
và localhost không dùng chung qua Internet. Bản sửa này không công bố website lên
Internet.

## Email confirmation và callback

Email/password login của tài khoản đã xác nhận không phụ thuộc URL callback.
Với đăng ký/xác nhận email hoặc OAuth, thêm URL host thật vào **Authentication →
URL Configuration → Redirect URLs**, ví dụ `http://192.168.1.10:3000/`, cùng
`http://127.0.0.1:3000/`, `http://localhost:3000/` và callback native hiện có.
Giữ URL host ổn định. Không tự nới allowlist của project trong bản sửa này.
Xem [quy tắc redirect chính thức](https://supabase.com/docs/guides/auth/redirect-urls).

Nếu tester đăng ký không nhận được email, kiểm tra SMTP và giới hạn gửi email
trong dashboard; việc có cấu hình client không tự cấu hình dịch vụ gửi thư.

## Kiểm tra

Kiểm thử dùng SDK thật với HTTP fixture cho password login/session/logout, thêm
kiểm tra cấu hình mặc định, override thiếu/sai, lỗi mạng/key và server static.
Main entry point mở Home; test kiểm tra đăng nhập tuỳ chọn không tự chuyển tab,
Món ăn / Recipes dùng được cho khách và không mở khai báo sức khoẻ. Xem [phạm vi MVP](product-scope.md).
Kiểm tra backend thực tế dùng public settings và một đăng nhập giả bị từ chối;
không sử dụng mật khẩu hay truy cập tài khoản riêng của người dùng.

Đã kiểm tra ngày 08/10/2026: 80 unit/widget/server test pass; static analysis
không báo lỗi; build web thành công không cần dart defines. Diagnostic riêng dùng
SDK thật nhận `invalid_credentials` cho thông tin giả, xác nhận URL/key được dịch
vụ Auth chấp nhận. Server chạy nền trả HTTP 200 tại `http://127.0.0.1:3000/` và
`http://192.168.2.28:3000/` từ máy host. IP có thể đổi khi kết nối lại Wi-Fi.
