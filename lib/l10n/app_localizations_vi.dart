// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get screeningNext => 'Tiếp tục';

  @override
  String get screeningGuidance => 'Thói quen nên trao đổi với nhóm điều trị';

  @override
  String get screeningTipDiabetes =>
      'Vì bạn khai báo đái tháo đường type 2: chọn nước lọc thay nước ngọt và trao đổi khẩu phần, giờ ăn với nhóm điều trị. Steady không tự đặt mục tiêu carbohydrate.';

  @override
  String get screeningTipSodium =>
      'Vì bạn khai báo tăng huyết áp: so sánh natri trên nhãn thực phẩm và dùng ít nước chấm mặn hơn. Hỏi bác sĩ trước khi dùng muối thay thế chứa kali.';

  @override
  String screeningProgress(int step) {
    return 'Bước $step/5';
  }

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Tạo tài khoản';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get authIntro =>
      'Đăng nhập để sàng lọc sức khoẻ và bắt đầu xây dựng thói quen cùng Steady.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get emailError => 'Nhập địa chỉ email hợp lệ.';

  @override
  String get passwordError =>
      'Nhập mật khẩu (ít nhất 8 ký tự khi tạo tài khoản).';

  @override
  String get authError =>
      'Không thể đăng nhập. Kiểm tra thông tin và kết nối rồi thử lại.';

  @override
  String get authSignupError =>
      'Không thể tạo tài khoản. Kiểm tra thông tin rồi thử lại.';

  @override
  String get authConfirmEmail =>
      'Kiểm tra email để xác nhận tài khoản, sau đó quay lại đây đăng nhập.';

  @override
  String get authConfiguration =>
      'Steady chưa được kết nối với dịch vụ đăng nhập. Cần thiết lập kết nối trước khi đăng nhập.';

  @override
  String get authInitializationError =>
      'Không thể khởi động dịch vụ đăng nhập. Kiểm tra kết nối và mở lại Steady để thử lại.';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get continueWithFacebook => 'Tiếp tục với Facebook';

  @override
  String get authOrEmail => 'hoặc dùng email';

  @override
  String get authProvidersUnavailable =>
      'Một số cách đăng nhập qua mạng xã hội chưa sẵn sàng. Bạn có thể dùng email.';

  @override
  String get authBrowserOpened =>
      'Hoàn tất đăng nhập trong trình duyệt. Nếu đã đóng trình duyệt, hãy chọn cách đăng nhập để thử lại.';

  @override
  String get authSocialError =>
      'Không thể bắt đầu đăng nhập qua mạng xã hội. Kiểm tra kết nối rồi thử lại, hoặc dùng email.';

  @override
  String get authCredentialsError =>
      'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';

  @override
  String get authRateLimitError =>
      'Bạn đã thử quá nhiều lần. Vui lòng đợi vài phút rồi thử lại.';

  @override
  String get authNetworkError =>
      'Không thể hoàn tất đăng nhập. Kiểm tra kết nối rồi thử lại.';

  @override
  String get authOffline =>
      'Kết nối bị gián đoạn. Phiên vẫn đang mở; hãy kiểm tra kết nối.';

  @override
  String get authSignOutError => 'Không thể đăng xuất. Vui lòng thử lại.';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get needAccount => 'Mới dùng Steady? Tạo tài khoản';

  @override
  String get screeningTitle => 'Cùng tìm hiểu sức khoẻ của bạn';

  @override
  String get screeningIntro =>
      'Chỉ số cơ thể → bệnh lý → dị ứng và sở thích ăn uống → mục tiêu tập luyện → kiểm tra và thực đơn.';

  @override
  String get screeningPrivacy =>
      'Câu trả lời chỉ giữ trong bộ nhớ ở phiên này, không tải lên mạng và được xoá khi đăng xuất hoặc đóng app. Bạn có thể chọn không chia sẻ.';

  @override
  String get screeningConditions => 'Bệnh nền và dị ứng';

  @override
  String get screeningConditionsHelp =>
      'Chọn tất cả bệnh đã được thông báo cho bạn. Đây là thông tin tự khai, chưa được xác minh. Chỉ để trống khi bạn biết mình không có bệnh nền.';

  @override
  String get screeningConditionsKnown =>
      'Tôi có thể khai báo bệnh nền (kể cả không có)';

  @override
  String get screeningAllergiesKnown =>
      'Tôi có thể khai báo dị ứng thực phẩm (kể cả không có)';

  @override
  String get screeningOtherAllergies =>
      'Dị ứng thực phẩm khác chưa có trong danh sách';

  @override
  String get screeningTreatment => 'Điều trị và khả năng ăn uống';

  @override
  String get screeningTreatmentHelp =>
      'Chọn tất cả mục phù hợp. Chỉ để trống khi bạn biết không có mục nào áp dụng. Thông tin tuỳ chọn giúp giải thích khi cần chuyên gia.';

  @override
  String get screeningTreatmentKnown =>
      'Tôi có thể khai báo tình trạng điều trị và ăn uống';

  @override
  String get screeningMedications => 'Thuốc đang dùng (tuỳ chọn)';

  @override
  String get screeningOrders => 'Chỉ định ăn uống của bác sĩ (tuỳ chọn)';

  @override
  String get screeningKidneyStage =>
      'Giai đoạn bệnh thận và lịch lọc máu nếu biết (tuỳ chọn)';

  @override
  String get screeningLabNotes =>
      'Xét nghiệm đã đo: giá trị, đơn vị, ngày và nguồn (tuỳ chọn)';

  @override
  String get screeningLabHelp =>
      'Bệnh thận: eGFR, kali và phospho; đái tháo đường: HbA1c. Ghi chú này không được diễn giải hay dùng để đặt giới hạn dinh dưỡng.';

  @override
  String get screeningReview => 'Kết quả sàng lọc';

  @override
  String get screeningLifestyle => 'Hỗ trợ lối sống cơ bản';

  @override
  String get screeningMoreInformation => 'Cần bổ sung thông tin';

  @override
  String get screeningProfessional => 'Cần đánh giá chuyên môn';

  @override
  String get screeningReasonChild =>
      'Thực đơn mẫu cho người lớn không áp dụng cho trẻ em và vị thành niên.';

  @override
  String get screeningReasonTreatment =>
      'Tình trạng điều trị, ăn uống hoặc thay đổi sức khoẻ gần đây cần được đánh giá riêng.';

  @override
  String get screeningReasonComplex =>
      'Một bệnh bạn khai báo nằm ngoài phạm vi tạo thực đơn mẫu tự động hiện tại của Steady.';

  @override
  String get screeningReasonOrders =>
      'Dữ liệu món ăn mẫu chưa đủ để kiểm tra và đáp ứng giới hạn ăn uống do bác sĩ chỉ định.';

  @override
  String get screeningReasonMedication =>
      'Tương tác thuốc–thực phẩm cần được rà soát. Steady không thay đổi hay diễn giải thuốc của bạn.';

  @override
  String get screeningReasonAllergy =>
      'Danh mục món ăn mẫu chưa kiểm tra được những dị ứng khác bạn vừa nhập.';

  @override
  String get screeningReasonKidney =>
      'Dinh dưỡng bệnh thận phụ thuộc giai đoạn, lọc máu, thuốc và xét nghiệm. Kể cả khi ghi chú đầy đủ, app vẫn không tự tạo chế độ điều trị.';

  @override
  String get screeningReasonWeightConflict =>
      'Tạm dừng lập thực đơn giảm cân tự động vì điều trị ung thư, ăn kém hoặc sụt cân ngoài ý muốn có thể thay đổi ưu tiên dinh dưỡng.';

  @override
  String get screeningReasonUnknown =>
      'Chưa đủ thông tin bệnh nền, dị ứng hoặc điều trị. Bạn vẫn có thể ghi nhận thói quen; thực đơn tự động được tạm dừng.';

  @override
  String get screeningReasonLifestyle =>
      'Bạn có thể theo dõi thói quen và dùng thực đơn minh hoạ. Kết quả này không xác nhận món ăn phù hợp để điều trị bệnh.';

  @override
  String get screeningConsent =>
      'Tôi đồng ý dùng các câu trả lời tự khai để hỗ trợ trong phiên này.';

  @override
  String get screeningConsentError =>
      'Vui lòng đồng ý sử dụng trong phiên, hoặc tiếp tục mà không chia sẻ thông tin sức khoẻ.';

  @override
  String get screeningDecline => 'Tiếp tục mà không chia sẻ thông tin sức khoẻ';

  @override
  String get screeningDeclined =>
      'Bạn chưa chia sẻ thông tin sức khoẻ. Thực đơn tự động được tạm dừng.';

  @override
  String get screeningContinue => 'Tiếp tục vào Steady';

  @override
  String get screeningEdit => 'Cập nhật sàng lọc sức khoẻ';

  @override
  String get screeningNote =>
      'Sàng lọc xác định phạm vi hỗ trợ của app, không chẩn đoán, kê chế độ ăn hay thay thế nhóm điều trị.';

  @override
  String get screeningPaused => 'Tạm dừng lập thực đơn';

  @override
  String get screeningSources => 'Đối chiếu nguồn: 7 tháng 10 năm 2026';

  @override
  String get conditionType1 => 'Đái tháo đường type 1';

  @override
  String get conditionType2 => 'Đái tháo đường type 2';

  @override
  String get conditionLung => 'COPD hoặc bệnh phổi mạn tính';

  @override
  String get conditionCancer => 'Ung thư';

  @override
  String get conditionKidney => 'Bệnh thận mạn';

  @override
  String get conditionTransplant => 'Ghép tạng hoặc tế bào gốc';

  @override
  String get conditionObesity => 'Thừa cân hoặc béo phì';

  @override
  String get conditionHeart => 'Suy tim, bệnh mạch vành hoặc bệnh cơ tim';

  @override
  String get conditionStroke => 'Bệnh mạch máu não hoặc tiền sử đột quỵ';

  @override
  String get conditionDown => 'Hội chứng Down';

  @override
  String get conditionHiv => 'HIV/AIDS';

  @override
  String get conditionNeurological => 'Bệnh thần kinh hoặc sa sút trí tuệ';

  @override
  String get conditionBlood =>
      'Hồng cầu hình liềm, thalassemia hoặc bệnh huyết học mạn';

  @override
  String get conditionAsthma => 'Hen phế quản';

  @override
  String get conditionHypertension => 'Tăng huyết áp';

  @override
  String get conditionImmunodeficiency => 'Thiếu hụt miễn dịch';

  @override
  String get conditionFattyLiver => 'Gan nhiễm mỡ do chuyển hoá';

  @override
  String get conditionOtherLiver => 'Xơ gan hoặc bệnh gan khác';

  @override
  String get conditionSubstance => 'Rối loạn do sử dụng chất gây nghiện';

  @override
  String get conditionImmunosuppression =>
      'Điều trị corticosteroid hoặc thuốc ức chế miễn dịch';

  @override
  String get conditionSystemic => 'Bệnh hệ thống (ví dụ lupus)';

  @override
  String get conditionCongenital => 'Bệnh bẩm sinh hoặc bệnh lý nhi khoa';

  @override
  String get conditionOther => 'Bệnh khác hoặc chế độ ăn điều trị';

  @override
  String get flagPregnancy => 'Mang thai hoặc cho con bú';

  @override
  String get flagEatingDisorder => 'Rối loạn ăn uống';

  @override
  String get flagDialysis => 'Đang lọc máu';

  @override
  String get flagChemotherapy => 'Đang hoá trị';

  @override
  String get flagInsulin => 'Đang dùng insulin';

  @override
  String get flagSwallowing => 'Khó nuốt';

  @override
  String get flagWeightLoss => 'Sụt cân ngoài ý muốn gần đây';

  @override
  String get flagPoorIntake => 'Chán ăn hoặc không ăn đủ';

  @override
  String get flagComplications => 'Biến chứng nặng hoặc bệnh chưa ổn định';

  @override
  String get today => 'Hôm nay';

  @override
  String get checkIn => 'Ghi nhận';

  @override
  String get rewards => 'Phần thưởng';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get meals => 'Bữa ăn';

  @override
  String get movedToday => 'Hôm nay bạn đã vận động.';

  @override
  String get makeTodayCount => 'Bắt đầu từ hôm nay.';

  @override
  String get consistencyMessage =>
      'Cứ tiếp tục nhé. Mỗi ngày vận động đều đưa bạn gần hơn tới mục tiêu.';

  @override
  String get movementMessage =>
      'Đi bộ, chạy, bơi hoặc chọn hoạt động bạn thích. Bắt đầu bằng một chút vận động hôm nay.';

  @override
  String get checkInComplete => 'Đã ghi nhận vận động hôm nay';

  @override
  String get noActivity => 'Chưa ghi nhận hoạt động';

  @override
  String get anyMovement => 'Mỗi chút vận động đều có ý nghĩa.';

  @override
  String get logAnother => 'Thêm hoạt động';

  @override
  String get thisWeek => '7 ngày gần nhất';

  @override
  String get dayStreak => 'ngày liên tiếp';

  @override
  String get steadyPoints => 'Điểm Steady';

  @override
  String get consistencyTip =>
      'Tạo thói quen với hoạt động bạn thích. Vận động đều đặn để tích điểm.';

  @override
  String get whatDidYouDo => 'Hôm nay bạn đã vận động thế nào?';

  @override
  String get activity => 'Hoạt động';

  @override
  String get duration => 'Thời lượng';

  @override
  String get manualActivity =>
      'Ghi lại hoạt động và thời lượng tại đây. Thông tin được nhập thủ công.';

  @override
  String get saveActivity => 'Lưu hoạt động';

  @override
  String get walk => 'Đi bộ';

  @override
  String get run => 'Chạy bộ';

  @override
  String get cycle => 'Đạp xe';

  @override
  String get swim => 'Bơi lội';

  @override
  String get gym => 'Tập gym';

  @override
  String get sport => 'Thể thao';

  @override
  String get mma => 'Võ MMA';

  @override
  String get other => 'Khác';

  @override
  String get rewardsIntro => 'Tích điểm bằng cách vận động đều đặn.';

  @override
  String get previewRewards => 'Phần thưởng mẫu';

  @override
  String get recoveryDay => 'Ngày phục hồi';

  @override
  String get partnerPerk => 'Ưu đãi đối tác';

  @override
  String get steadyBadge => 'Huy hiệu Steady';

  @override
  String get rewardsNote =>
      'Đây là các phần thưởng mẫu. Tính năng đổi thưởng chưa khả dụng.';

  @override
  String get member => 'Thành viên Steady';

  @override
  String get memberGoal => 'Mục tiêu: duy trì vận động đều đặn';

  @override
  String get weeklyTarget => 'Mục tiêu tuần';

  @override
  String get fiveDays => '5 ngày vận động';

  @override
  String get reminders => 'Nhắc nhở';

  @override
  String get notConnected => 'Chưa kết nối';

  @override
  String get healthData => 'Dữ liệu sức khoẻ';

  @override
  String get manualCheckIns => 'Hoạt động được nhập thủ công';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageHelp => 'Chọn ngôn ngữ hiển thị của Steady.';

  @override
  String get systemLanguage => 'Theo thiết bị';

  @override
  String get languageSaveError =>
      'Đã đổi ngôn ngữ trong phiên này nhưng chưa lưu được lựa chọn.';

  @override
  String get mealsTitle => 'Bữa ăn dễ dàng hơn';

  @override
  String get mealsIntro =>
      'Món Việt quen thuộc. Lên thực đơn một tuần phù hợp với sinh hoạt của bạn.';

  @override
  String get setupTitle => 'Cùng lên thực đơn tuần';

  @override
  String get setupIntro =>
      'Ba bước để chọn món theo sở thích, thời gian và ngân sách.';

  @override
  String get bodyGoal => 'Thông tin của bạn';

  @override
  String get health => 'Sức khoẻ';

  @override
  String get preferences => 'Thói quen ăn uống';

  @override
  String get bodyGoalHelp => 'Bắt đầu với số đo và mục tiêu của bạn.';

  @override
  String get age => 'Tuổi';

  @override
  String get height => 'Chiều cao (cm)';

  @override
  String get weight => 'Cân nặng (kg)';

  @override
  String get goal => 'Mục tiêu';

  @override
  String get dailyActivity => 'Mức vận động thường ngày';

  @override
  String get balanced => 'Ăn uống cân bằng';

  @override
  String get weightLoss => 'Hỗ trợ giảm cân';

  @override
  String get muscle => 'Hỗ trợ tăng cơ';

  @override
  String get sedentary => 'Ít vận động';

  @override
  String get lightActivity => 'Nhẹ: 1–2 buổi/tuần';

  @override
  String get moderateActivity => 'Vừa: 3–4 buổi/tuần';

  @override
  String get highActivity => 'Nhiều: 5+ buổi/tuần';

  @override
  String get cholesterolStatus => 'Chẩn đoán cholesterol cao';

  @override
  String get unknown => 'Chưa biết';

  @override
  String get confirmed => 'Đã được bác sĩ xác nhận';

  @override
  String get notDiagnosed => 'Chưa được chẩn đoán';

  @override
  String get healthHelp =>
      'Có thể bỏ qua các chỉ số tuỳ chọn. Chỉ nhập kết quả đo hoặc xét nghiệm; Steady không chẩn đoán hay diễn giải chỉ số.';

  @override
  String get optionalReadings => 'Thêm huyết áp hoặc xét nghiệm';

  @override
  String get optional => 'Tuỳ chọn';

  @override
  String get systolic => 'Tâm thu (mmHg)';

  @override
  String get diastolic => 'Tâm trương (mmHg)';

  @override
  String get ldl => 'LDL (mmol/L)';

  @override
  String get hdl => 'HDL (mmol/L)';

  @override
  String get triglycerides => 'Triglyceride (mmol/L)';

  @override
  String get professionalLabel => 'Tôi cần chế độ ăn từ chuyên gia';

  @override
  String get professionalHelp =>
      'Mang thai, cho con bú, bệnh thận, rối loạn ăn uống hoặc đang có chế độ ăn điều trị riêng.';

  @override
  String get diet => 'Chế độ ăn';

  @override
  String get omnivore => 'Ăn đa dạng';

  @override
  String get vegetarian => 'Ăn chay';

  @override
  String get budget => 'Ngân sách mỗi ngày (VND)';

  @override
  String get cookingTime => 'Thời gian tối đa mỗi món (phút)';

  @override
  String get allergens => 'Dị ứng và thành phần loại trừ';

  @override
  String get allergensHelp =>
      'Thành phần đã chọn luôn được loại trừ khi tạo thực đơn hoặc đổi món.';

  @override
  String get dislikes => 'Nguyên liệu bạn không thích';

  @override
  String get soy => 'Đậu nành';

  @override
  String get fish => 'Cá';

  @override
  String get gluten => 'Gluten';

  @override
  String get milk => 'Sữa';

  @override
  String get egg => 'Trứng';

  @override
  String get peanut => 'Lạc';

  @override
  String get nuts => 'Hạt cây';

  @override
  String get shellfish => 'Hải sản có vỏ';

  @override
  String get sesame => 'Mè';

  @override
  String get consent =>
      'Dùng thông tin của tôi để tạo thực đơn trong phiên này';

  @override
  String get privacyNote =>
      'Hồ sơ và thực đơn chỉ giữ trong bộ nhớ của thiết bị, mất khi đóng app và không gửi tới AI hay máy chủ.';

  @override
  String get createPlan => 'Tạo thực đơn 7 ngày';

  @override
  String get updatePlan => 'Cập nhật thực đơn';

  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get back => 'Quay lại';

  @override
  String get cancel => 'Huỷ';

  @override
  String get integerError => 'Vui lòng nhập số nguyên';

  @override
  String get bloodPressurePairError =>
      'Nhập cả hai chỉ số huyết áp hoặc để trống cả hai.';

  @override
  String get bloodPressureOrderError =>
      'Huyết áp tâm thu cần lớn hơn tâm trương.';

  @override
  String get consentError =>
      'Vui lòng đồng ý sử dụng thông tin để tạo thực đơn.';

  @override
  String get planReady => 'Thực đơn tuần đã sẵn sàng';

  @override
  String get planUpdated => 'Đã cập nhật thực đơn';

  @override
  String get yourWeek => 'Thực đơn 7 ngày của bạn';

  @override
  String get editProfile => 'Chỉnh sửa thông tin';

  @override
  String get dailyBudget => 'Ngân sách ngày';

  @override
  String get estimatedCost => 'Chi phí ước tính';

  @override
  String get energy => 'Năng lượng';

  @override
  String get protein => 'Đạm';

  @override
  String get fibre => 'Chất xơ';

  @override
  String get saturatedFat => 'Chất béo bão hoà';

  @override
  String get estimatedDaily => 'Tổng ước tính trong ngày';

  @override
  String get breakfast => 'Bữa sáng';

  @override
  String get lunch => 'Bữa trưa';

  @override
  String get dinner => 'Bữa tối';

  @override
  String get ingredients => 'Nguyên liệu';

  @override
  String get preparation => 'Cách chế biến';

  @override
  String get recipeDetails => 'Nguyên liệu và cách làm';

  @override
  String get swapMeal => 'Đổi món';

  @override
  String get noAlternatives => 'Chưa có món thay thế';

  @override
  String get swapTitle => 'Chọn món thay thế';

  @override
  String get swapHelp =>
      'Các món này phù hợp với chế độ ăn, loại trừ, thời gian và ngân sách đã chọn.';

  @override
  String get groceries => 'Danh sách mua sắm';

  @override
  String get groceriesWeek => 'Danh sách mua sắm · 7 ngày';

  @override
  String get groceriesHelp =>
      'Khối lượng cho cả tuần. Đậu ghi “chín” tính theo khối lượng đã nấu; nguyên liệu khác tính theo phần ăn được trước chế biến.';

  @override
  String get planNotes => 'Về thực đơn mẫu này';

  @override
  String get nutritionNote =>
      'Dinh dưỡng và giá món là ước tính, chưa phải dữ liệu lâm sàng kiểm chứng hay giá trực tiếp. Lượng nguyên liệu thay đổi theo khẩu phần; thời gian nấu giả định mẻ nhỏ tại nhà. Natri chưa gồm muối/nước chấm thêm: kiểm tra nhãn và tính cả gia vị. Thực đơn mẫu không bảo đảm phù hợp điều trị hoặc đủ mọi vi chất.';

  @override
  String get personalisationNote =>
      'Cấu hình nhiều lớp đặt mục tiêu calorie/macro ước tính ban đầu. Khẩu phần được ghép theo mục tiêu, đồng thời giữ dị ứng, chế độ ăn, thời gian và ngân sách. Yêu cầu sức khoẻ luôn ưu tiên hơn sở thích tập luyện.';

  @override
  String get unsupportedTitle => 'Bạn cần thực đơn từ chuyên gia';

  @override
  String get unsupportedHelp =>
      'Chưa tạo thực đơn tự động cho người dưới 18 tuổi hoặc cần chế độ ăn điều trị riêng. Hãy trao đổi với chuyên gia dinh dưỡng để có thực đơn phù hợp.';

  @override
  String get emptyPlanTitle => 'Chưa tìm được thực đơn phù hợp';

  @override
  String get emptyPlanHelp =>
      'Chưa có thực đơn đáp ứng đồng thời calorie, macro, dị ứng, thực phẩm, thời gian và ngân sách. Hãy chỉnh thông tin; Steady không tự bỏ ràng buộc.';

  @override
  String get deletePlan => 'Xoá hồ sơ và thực đơn';

  @override
  String get deleteTitle => 'Xoá thông tin bữa ăn?';

  @override
  String get deleteHelp =>
      'Thao tác này xoá số đo, chỉ số sức khoẻ, thói quen ăn uống và thực đơn trong phiên này. Sau đó bạn có thể tạo lại.';

  @override
  String get delete => 'Xoá';

  @override
  String get deleted => 'Đã xoá hồ sơ và thực đơn';

  @override
  String get close => 'Đóng';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get notCompleted => 'Chưa vận động';

  @override
  String minutesValue(int count) {
    return '$count phút';
  }

  @override
  String pointsValue(int count) {
    return '$count điểm';
  }

  @override
  String activitySaved(String activity, int points) {
    return 'Đã ghi nhận $activity. +$points điểm';
  }

  @override
  String rangeError(String min, String max) {
    return 'Nhập giá trị từ $min đến $max';
  }

  @override
  String stepProgress(int step) {
    return 'Bước $step/3';
  }

  @override
  String dayNumber(int day) {
    return 'Ngày $day';
  }

  @override
  String mealSwapped(String meal) {
    return 'Đã đổi sang $meal';
  }

  @override
  String itemsCount(int count) {
    return '$count nguyên liệu';
  }

  @override
  String get oatsIngredient => 'Yến mạch';

  @override
  String get banana => 'Chuối';

  @override
  String get soyMilk => 'Sữa đậu nành không đường';

  @override
  String get sweetPotato => 'Khoai lang';

  @override
  String get cookedSoybeans => 'Đậu nành chín';

  @override
  String get guava => 'Ổi';

  @override
  String get mungBeans => 'Đậu xanh';

  @override
  String get brownRice => 'Gạo lứt';

  @override
  String get cookedRedBeans => 'Đậu đỏ chín';

  @override
  String get cucumber => 'Dưa chuột';

  @override
  String get canolaOil => 'Dầu cải';

  @override
  String get tilapia => 'Cá rô phi phi lê';

  @override
  String get greens => 'Rau cải';

  @override
  String get tofuIngredient => 'Đậu phụ';

  @override
  String get tomato => 'Cà chua';

  @override
  String get carrot => 'Cà rốt';

  @override
  String get chickenBreast => 'Ức gà bỏ da';

  @override
  String get mushrooms => 'Nấm';

  @override
  String get oatsName => 'Cháo yến mạch chuối';

  @override
  String get oatsRecipe =>
      'Nấu yến mạch với sữa đậu nành và nước 5–7 phút. Thêm chuối. Không thêm đường.';

  @override
  String get sweetName => 'Khoai lang, đậu nành và trái cây';

  @override
  String get sweetRecipe =>
      'Hấp khoai lang 15–20 phút. Ăn cùng đậu nành đã nấu chín và ổi rửa sạch.';

  @override
  String get beanbreakfastName => 'Cháo đậu xanh và chuối';

  @override
  String get beanbreakfastRecipe =>
      'Ngâm đậu và gạo trước. Nấu với nước đến mềm; dùng nồi áp suất để tiết kiệm thời gian. Ăn chuối riêng.';

  @override
  String get ricebreakfastName => 'Cơm lứt đậu đỏ, dưa chuột';

  @override
  String get ricebreakfastRecipe =>
      'Dùng cơm đã nấu và đậu đã luộc. Hâm nóng, ăn cùng dưa chuột và dầu cải.';

  @override
  String get fishName => 'Cơm lứt cá hấp và rau';

  @override
  String get fishRecipe =>
      'Nấu cơm. Hấp cá với gừng 10–15 phút đến chín. Luộc rau, thêm dầu cải. Gia vị và nước chấm tính riêng.';

  @override
  String get tofuName => 'Đậu phụ sốt cà chua, cơm lứt';

  @override
  String get tofuRecipe =>
      'Nấu cơm. Đun cà chua với ít nước và dầu, thêm đậu phụ; ăn cùng rau luộc. Không chiên ngập dầu.';

  @override
  String get lentilName => 'Cơm đậu xanh và rau củ';

  @override
  String get lentilRecipe =>
      'Dùng đậu đã ngâm và cơm đã nấu. Nấu đậu chín mềm, thêm cà rốt và rau; trộn với cơm và dầu.';

  @override
  String get chickenName => 'Ức gà áp chảo, cơm và rau';

  @override
  String get chickenRecipe =>
      'Nấu cơm. Áp chảo gà bỏ da với dầu đến chín kỹ. Ăn với rau hấp; hạn chế nước sốt đóng chai.';

  @override
  String get beanDinnerName => 'Đậu đỏ, khoai lang và rau xanh';

  @override
  String get beanDinnerRecipe =>
      'Hấp khoai. Hâm đậu đỏ đã nấu chín; ăn với rau luộc và dầu cải.';

  @override
  String get fishDinnerName => 'Cá hấp, khoai lang và rau';

  @override
  String get fishDinnerRecipe =>
      'Hấp khoai và cá đến chín, luộc rau. Dùng gừng và chanh; nước chấm tính riêng.';

  @override
  String get tofuDinnerName => 'Đậu phụ hấp nấm và cơm lứt';

  @override
  String get tofuDinnerRecipe =>
      'Hấp đậu phụ với nấm đến nóng và chín. Ăn cùng cơm lứt, rau và dầu cải.';

  @override
  String get chickenDinnerName => 'Gà bỏ da, khoai và rau';

  @override
  String get chickenDinnerRecipe =>
      'Hấp khoai, luộc hoặc áp chảo gà đến chín kỹ. Ăn cùng rau luộc.';

  @override
  String get nutritionBodyMeasurements => 'Chỉ số cơ thể';

  @override
  String get nutritionBodyFat => 'Tỷ lệ mỡ cơ thể (%)';

  @override
  String get nutritionBodyFatHelp =>
      'Nhập số đo nếu có; để trống nếu chưa biết. Steady không suy ra body fat từ BMI.';

  @override
  String get nutritionSex => 'Giới tính dùng để ước tính năng lượng';

  @override
  String get nutritionSexHelp =>
      'Công thức Mifflin–St Jeor dùng giới tính, tuổi, chiều cao và cân nặng. Nếu bỏ qua giới tính, Steady không tự đoán mục tiêu calorie.';

  @override
  String get nutritionSexUnspecified => 'Bỏ qua ước tính năng lượng';

  @override
  String get nutritionSexFemale => 'Nữ';

  @override
  String get nutritionSexMale => 'Nam';

  @override
  String get nutritionFoodSource => 'Nguồn thực phẩm';

  @override
  String get nutritionFoodPattern => 'Kiểu thực phẩm';

  @override
  String get nutritionMacroStrategy => 'Chiến lược macro';

  @override
  String get nutritionMealTiming => 'Lịch ăn';

  @override
  String get nutritionEnergyStrategy => 'Chiến lược năng lượng';

  @override
  String get nutritionTrainingGoal => 'Tập luyện và mục tiêu cơ thể';

  @override
  String get nutritionTrainingSessions => 'Số buổi tập kháng lực/tuần';

  @override
  String get nutritionExperience => 'Kinh nghiệm tập luyện';

  @override
  String get nutritionBeginner => 'Mới tập / quay lại tập';

  @override
  String get nutritionIntermediate => 'Đã tập thường xuyên';

  @override
  String get nutritionAdvanced => 'Tập lâu năm';

  @override
  String get nutritionGoalHealth => 'Sức khoẻ tổng thể';

  @override
  String get nutritionGoalFatLoss => 'Giảm mỡ, giữ cơ';

  @override
  String get nutritionGoalMuscle => 'Tăng cơ';

  @override
  String get nutritionGoalRecomp => 'Giảm mỡ và tăng/giữ cơ';

  @override
  String get nutritionGoalPerformance => 'Sức mạnh / hiệu suất';

  @override
  String get nutritionGoalEndurance => 'Sức bền';

  @override
  String get nutritionMaintenance => 'Duy trì năng lượng';

  @override
  String get nutritionDeficit => 'Cut vừa phải';

  @override
  String get nutritionLeanBulk => 'Lean bulk — tăng cơ có kiểm soát';

  @override
  String get nutritionAggressiveBulk =>
      'Aggressive bulk (thường gọi dirty bulk)';

  @override
  String get nutritionRecompEnergy => 'Recomp ở mức duy trì';

  @override
  String get nutritionBalancedMacro => 'Macro cân bằng';

  @override
  String get nutritionHighProtein => 'Cân bằng, ưu tiên protein';

  @override
  String get nutritionLowCarb => 'Ít carbohydrate';

  @override
  String get nutritionKeto => 'Keto';

  @override
  String get nutritionLowFat => 'Ít chất béo';

  @override
  String get nutritionBalancedPattern => 'Thực phẩm đa dạng';

  @override
  String get nutritionMediterranean => 'Phong cách Địa Trung Hải';

  @override
  String get nutritionDash => 'Phong cách DASH';

  @override
  String get nutritionPaleo => 'Paleo';

  @override
  String get nutritionVegan => 'Thuần chay';

  @override
  String get nutritionThreeMeals => '3 bữa/ngày';

  @override
  String get nutritionFourMeals => '3 bữa + 1 bữa phụ';

  @override
  String get nutritionTimeRestricted => '16:8 — ăn trong khung 12:00–20:00';

  @override
  String get nutritionPreferenceHelp =>
      'Nguồn thực phẩm, macro và lịch ăn là các lựa chọn riêng. Dị ứng và yêu cầu sức khoẻ luôn được ưu tiên.';

  @override
  String get nutritionGenerate => 'Hoàn tất và tạo thực đơn';

  @override
  String get nutritionConfiguration => 'Cấu hình dinh dưỡng của bạn';

  @override
  String get nutritionMaintenanceEstimate => 'Ước tính năng lượng duy trì';

  @override
  String get nutritionDailyTarget => 'Mục tiêu ban đầu mỗi ngày';

  @override
  String get nutritionCarbs => 'Carbohydrate';

  @override
  String get nutritionFat => 'Chất béo';

  @override
  String get nutritionSodium => 'Natri';

  @override
  String get nutritionPortion => 'Hệ số khẩu phần';

  @override
  String get nutritionMedicalReview =>
      'Thông tin sức khoẻ cần bổ sung hoặc đánh giá chuyên môn trước khi tạo thực đơn tự động.';

  @override
  String get nutritionInvalidMeasurements =>
      'Kiểm tra chỉ số cơ thể và thông tin vận động trước khi ước tính thực đơn.';

  @override
  String get nutritionNeedSex =>
      'Chưa ước tính năng lượng. Cập nhật giới tính dùng trong công thức để tạo thực đơn theo mục tiêu calorie ước tính.';

  @override
  String get nutritionGoalConflict =>
      'Mục tiêu và chiến lược năng lượng đang mâu thuẫn. Hãy chọn lại trước khi tạo thực đơn.';

  @override
  String get nutritionLowWeightReview =>
      'Thâm hụt năng lượng khi cân nặng thấp so với chiều cao cần đánh giá chuyên môn. Steady không tự tạo kế hoạch cut.';

  @override
  String get nutritionKetoReview =>
      'Keto khi có bệnh lý đã khai hoặc dùng thuốc SGLT2 cần bác sĩ đánh giá. Steady không tạo thực đơn keto tự động.';

  @override
  String get nutritionBulkReview =>
      'Aggressive bulk khi có bệnh lý đã khai cần đánh giá chuyên môn. Chọn chiến lược phù hợp cùng người điều trị.';

  @override
  String get nutritionPatternConflict =>
      'Paleo loại các loại đậu và ngũ cốc của bộ món chay hiện có. Cần đổi lựa chọn; Steady không tự bỏ qua sở thích.';

  @override
  String get nutritionEstimateUnavailable =>
      'Ước tính từ các thông tin này nằm ngoài phạm vi Steady hỗ trợ. Cập nhật thông tin hoặc xin đánh giá chuyên môn.';

  @override
  String get nutritionEstimateNote =>
      'Calorie và macro là ước tính ban đầu, không phải chỉ định điều trị. Body fat được lưu riêng, không dùng để chẩn đoán. Điều chỉnh dựa trên xu hướng cân nặng và đáp ứng tập luyện.';

  @override
  String get nutritionBulkTradeoff =>
      'Aggressive bulk là mức dư năng lượng lớn hơn, không phải ăn thực phẩm kém chất lượng. Tăng cân nhanh có thể kèm tăng mỡ; không bảo đảm cơ tăng nhanh hơn.';

  @override
  String get nutritionTrainingNote =>
      'Tăng cơ và recomp còn cần tập kháng lực tiến bộ và hồi phục. Thực đơn không bảo đảm kết quả thay đổi cơ thể.';

  @override
  String get nutritionKetoPerformance =>
      'Keto không phải lựa chọn ưu tiên cho tập cường độ hoặc khối lượng cao. Không bảo đảm lợi thế hiệu suất hay đạt ketosis.';

  @override
  String get nutritionVeganNote =>
      'Thực đơn thuần chay cần chú ý B12, sắt, calcium, iodine và omega-3. Bộ món hiện tại chưa kiểm chứng đủ vi chất.';

  @override
  String get flagSglt2 =>
      'Đang dùng thuốc SGLT2 (như dapagliflozin hoặc empagliflozin)';

  @override
  String get snack => 'Bữa phụ';

  @override
  String get eggIngredient => 'Trứng';

  @override
  String get avocadoIngredient => 'Bơ quả';

  @override
  String get tofuScrambleName => 'Đậu phụ xào rau';

  @override
  String get tofuScrambleRecipe =>
      'Làm nóng đậu phụ và rau với dầu; dùng đậu phụ không tẩm ướp. Không thêm nước sốt mặn.';

  @override
  String get eggPotatoName => 'Trứng, khoai lang và rau';

  @override
  String get eggPotatoRecipe =>
      'Luộc trứng chín kỹ, hấp khoai và rau; trộn rau với dầu. Không thêm muối.';

  @override
  String get ketoEggName => 'Trứng và bơ';

  @override
  String get ketoEggRecipe =>
      'Lu?c tr?ng ch?n k?. ?n c?ng b? qu? v? d?a chu?t, tr?n rau v?i to?n b? l??ng d?u ghi trong nguy?n li?u; kh?ng th?m mu?i.';

  @override
  String get ketoChickenName => 'Salad gà và bơ';

  @override
  String get ketoChickenRecipe =>
      'Nấu chín kỹ gà và rau. Ăn cùng bơ quả, dầu và chanh; không thêm sốt mặn.';

  @override
  String get ketoFishName => 'Cá hấp và rau ít tinh bột';

  @override
  String get ketoFishRecipe =>
      'Hấp cá chín kỹ và luộc rau; ăn cùng dầu và chanh. Không thêm muối hay nước chấm.';

  @override
  String get ketoTofuLunchName => 'Đậu phụ và bơ quả';

  @override
  String get ketoTofuLunchRecipe =>
      'Nấu chín đậu phụ không tẩm ướp. Ăn với bơ quả, dưa chuột và dầu; không thêm muối.';

  @override
  String get ketoTofuDinnerName => 'Đậu phụ, nấm và rau';

  @override
  String get ketoTofuDinnerRecipe =>
      'Nấu chín đậu phụ, nấm và rau với dầu. Không thêm muối hay nước sốt.';

  @override
  String get soySnackName => 'Đậu nành và ổi';

  @override
  String get soySnackRecipe =>
      'Hâm nóng đậu nành đã luộc không muối. Ăn cùng ổi rửa sạch.';

  @override
  String get eggSnackName => 'Trứng và dưa chuột';

  @override
  String get eggSnackRecipe =>
      'Luộc trứng chín kỹ. Ăn cùng dưa chuột rửa sạch; không thêm muối.';

  @override
  String get paleoChickenName => 'G?, khoai lang v? rau c?';

  @override
  String get paleoChickenRecipe =>
      'N?u ch?n k? g?, h?p khoai v? rau. D?ng to?n b? l??ng d?u ghi trong nguy?n li?u ?? tr?n rau; kh?ng th?m mu?i.';
}
