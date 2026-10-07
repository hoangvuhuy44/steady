# Kê khai và tạo thực đơn Steady

Áp dụng cấu trúc trong [chat log người dùng cung cấp](https://chatgpt.com/s/t_6ac5f957a3288191b99409e456c4c046), đối chiếu các nguồn dưới đây ngày 07/10/2026. Chat log là yêu cầu thiết kế, không phải bằng chứng lâm sàng.

## Luồng sau đăng nhập

1. Tuổi, chiều cao, cân nặng, body fat nếu đã đo, giới tính dùng trong công thức năng lượng.
2. Bệnh lý tự khai, điều trị, thuốc, chỉ định của bác sĩ và ghi chú xét nghiệm.
3. Dị ứng, nguyên liệu không thích, nguồn thực phẩm, kiểu ăn, tỷ lệ macro, lịch bữa ăn, ngân sách và thời gian nấu.
4. Mục tiêu tập luyện, chiến lược năng lượng, mức vận động tổng thể, số buổi tập kháng lực và kinh nghiệm.
5. Xem lại phạm vi hỗ trợ, mục tiêu ước tính và đồng ý sử dụng dữ liệu trong phiên. App tạo thực đơn rồi mở tab Bữa ăn.

Body fat tùy chọn, không suy ra từ BMI và không dùng để chẩn đoán hay chọn ngưỡng bulk/cut. Có thể bỏ qua giới tính; khi đó app không tự ước tính calorie. Chỉnh sửa quay về cùng luồng với các câu trả lời trước.

Mục tiêu, năng lượng, macro, nguồn thực phẩm và lịch ăn là độc lập. Đổi mục tiêu gợi ý chiến lược năng lượng mặc định. Tổ hợp mâu thuẫn như giảm mỡ với bulk không tạo thực đơn. Dirty bulk được gọi là **Aggressive bulk**, có giải thích tăng mỡ; chất lượng thực phẩm thấp không được dùng như một chiến lược.

## Mục tiêu ban đầu

`NutritionTargets` dùng Mifflin–St Jeor: `10 × kg + 6.25 × cm − 5 × tuổi + 5` với nam, hoặc `−161` với nữ. Nhân hệ số vận động 1.2 / 1.375 / 1.55 / 1.725. Đây là hệ số thực hành của sản phẩm, không phải phép đo chuyển hóa. Mức vận động bao gồm sinh hoạt và tập luyện; số buổi kháng lực không cộng calorie lần thứ hai.

| Chiến lược | Năng lượng so với duy trì |
| --- | --- |
| Duy trì / recomposition | 100% |
| Giảm mỡ | 85% |
| Lean bulk | 110%; người tập nâng cao 105% |
| Aggressive bulk | 115% |

Protein khởi điểm 1.8 g/kg khi tập kháng lực, tăng cơ, giảm mỡ, recomposition, bulk hoặc high-protein; Keto còn lại 1.6 g/kg; sức khỏe tổng thể còn lại 1.2 g/kg. Đây không phải lượng tối ưu đã được xác nhận cho từng người.

Macro cân bằng/high-protein dành 30% năng lượng cho chất béo; low-fat 20%; low-carb 25% cho carbohydrate; Keto đặt mục tiêu carbohydrate 30 g/ngày, chất béo nhận năng lượng còn lại. Menu Keto giới hạn tổng carbohydrate ≤50 g/ngày và chất béo ≥55% năng lượng; không bảo đảm ketosis. Keto với mục tiêu hiệu suất/sức bền/tăng cơ có lưu ý hiệu suất tập luyện.

Ước tính dưới năng lượng nghỉ, ngoài 1.200–4.500 kcal, macro âm hoặc chất béo dưới 0.5 g/kg bị từ chối. Đây là phạm vi sản phẩm, không xác nhận nhu cầu thực tế. Mifflin–St Jeor được phát triển trên người khỏe mạnh 19–78 tuổi; nhóm khác hoặc cơ thể đặc biệt có thể sai lệch đáng kể.

## Sinh và đổi món

`MealPlanner` tìm tổ hợp từ **22 công thức mẫu**, thử khẩu phần 0.75–2 lần, chọn thực đơn 7 ngày với ít lặp món hơn. Không gọi dịch vụ AI. Ba bữa, bốn bữa có bữa phụ, hoặc lịch gợi ý 16:8 có giờ ăn khác nhau; đây không phải chỉ định nhịn ăn điều trị.

- Dị ứng, nguyên liệu không thích, vegetarian/vegan, thời gian và ngân sách là ràng buộc bắt buộc.
- Mỗi ngày: calorie 90–110%, protein 90–130% mục tiêu; ngoài Keto, carbohydrate 75–125% và chất béo 70–130%. Đây là dung sai tìm kiếm của sản phẩm.
- Chất xơ ≥25 g/ngày; natri ≤2.300 mg, hoặc ≤1.500 mg khi tăng huyết áp/chọn DASH; chất béo bão hòa ≤10% năng lượng, ≤6% nếu trường cholesterol cũ là đã xác nhận.
- Mediterranean style thêm giới hạn chất béo bão hòa ≤7% năng lượng thực đơn. DASH/Mediterranean là bản thích nghi từ món Việt, chưa đánh giá đầy đủ nhóm thực phẩm và vi chất của chế độ gốc. Paleo loại ngũ cốc/đậu trong danh mục; không chứng nhận Paleo chuẩn.
- Khẩu phần thay đổi gram, dinh dưỡng và chi phí. Thời gian nấu giả định mẻ nấu gia đình nhỏ, không tăng tuyến tính theo gram.
- Đổi món kiểm tra lại **cả ngày**. Store dùng dữ liệu công thức chuẩn để ngăn đối tượng món bị sửa số liệu vượt ràng buộc.
- Mua sắm cộng gram khẩu phần thực tế. Không có tổ hợp thì hiển thị không có thực đơn; không tự bỏ dị ứng hay vượt ngân sách.

## Bệnh lý có quyền ưu tiên

[Screening](health-screening.md) được kiểm tra trước ước tính và sinh/đổi món. Bệnh thận, điều trị phức tạp, mang thai/cho con bú, rối loạn ăn uống, thuốc hoặc chỉ định ăn điều trị chưa mô hình hóa cần chuyên gia đánh giá. Không áp dụng protein bodybuilding cho bệnh thận. Keto với bệnh nền ngoài hen, đặc biệt thuốc SGLT2, và Aggressive bulk với bệnh nền ngoài hen cũng cần đánh giá. Chọn chế độ ăn không thể vượt quy tắc.

Tăng huyết áp có giới hạn natri ước tính; một số bệnh nền ổn định chỉ có hướng dẫn lối sống chung. App không tạo chế độ điều trị đã được kiểm chứng cho tiểu đường, bệnh thận, ung thư hay bệnh gan. Không suy luận thuốc, xét nghiệm và mức độ bệnh từ văn bản tự do.

## Dữ liệu và giới hạn

Dinh dưỡng công thức và giá là **ước tính của nhà phát triển**, chưa tính từ cơ sở thành phần thực phẩm đã kiểm chứng, nhãn sản phẩm hay giá thị trường. Loại thực phẩm/cách nấu có thể làm thay đổi số liệu. Gia vị thêm, nước chấm, đồ uống và món thêm không nằm trong tổng. Natri/macro thực tế có thể khác mục tiêu. Cần xác minh dữ liệu trước khi dùng lâm sàng.

Dữ liệu sức khỏe và thực đơn giữ trong phiên, chưa đồng bộ bảng Supabase. Chưa có nhật ký xu hướng cân nặng/vòng eo và tự hiệu chỉnh nhiều tuần; người dùng cập nhật thông tin và sinh lại thực đơn. Không có điểm số tương thích hoặc dự đoán tốc độ tăng cơ/giảm mỡ.

## Nguồn đối chiếu

- [Mifflin–St Jeor, nghiên cứu gốc](https://pubmed.ncbi.nlm.nih.gov/2305711/): phương trình năng lượng nghỉ.
- [Thử nghiệm mức dư năng lượng nhỏ và lớn](https://pmc.ncbi.nlm.nih.gov/articles/PMC10620361/): dư năng lượng lớn có thể tăng nếp gấp da nhiều hơn mà không tăng cơ/sức mạnh tương ứng. Hệ số trên là quyết định sản phẩm.
- [Tổng quan dinh dưỡng giai đoạn tăng cơ](https://pmc.ncbi.nlm.nih.gov/articles/PMC6680710/): mức dư thận trọng, protein 1.6–2.2 g/kg trong bối cảnh tập thể hình.
- [ISSN 2024: ketogenic diets](https://pubmed.ncbi.nlm.nih.gov/38934469/): Keto không phải mặc định tốt hơn cho mọi mục tiêu tập luyện.
- [NHLBI: following DASH](https://www.nhlbi.nih.gov/health/dash/following-dash): mức natri 2.300/1.500 mg.
- [AHA: saturated fats](https://www.heart.org/en/healthy-living/healthy-eating/eat-smart/fats/saturated-fats): giảm chất béo bão hòa, ưu tiên chất béo không bão hòa.
- [NIDDK: kidney nutrition](https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd/healthy-eating-adults-chronic-kidney-disease): cá thể hóa protein/khoáng chất.
- [ADA: SGLT inhibitors and ketoacidosis](https://diabetesjournals.org/care/article-abstract/42/6/1147/36001): chế độ rất ít carbohydrate/ketogenic cần đánh giá khi dùng SGLT inhibitors.

Kiểm thử xác nhận hành vi phần mềm và bố cục Việt/Anh với cỡ chữ lớn; không xác nhận hiệu quả lâm sàng của thực đơn.

## Ki?m tra ng?y 07/10/2026

Ph?n t?ch Flutter kh?ng b?o l?i; 71 ki?m th? unit/widget ?? qua. Ki?m th? d?ng
?nh Vi?t/Anh c?ng ?? qua. Xem [m?c ti?u v? t?ng dinh d??ng](screenshots/screening-vi-portions.png)
v? [b??c m?c ti?u t?p luy?n](screenshots/screening-vi-training.png).
