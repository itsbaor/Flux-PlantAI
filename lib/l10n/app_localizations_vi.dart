// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Plant AI';

  @override
  String get welcome => 'Xin chào,';

  @override
  String get home => 'Trang chủ';

  @override
  String get myGarden => 'Vườn của tôi';

  @override
  String get reminder => 'Nhắc nhở';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get identifyYourPlant => 'Nhận diện\nCây của bạn';

  @override
  String get scanToIdentify =>
      'Quét để nhận diện loài và\nnhận hướng dẫn chăm sóc';

  @override
  String get scanNow => 'Quét ngay';

  @override
  String get scanAPlant => 'Quét một cây';

  @override
  String get yourTasksForToday => 'Nhiệm vụ hôm nay';

  @override
  String get noPlantsInGardenYet => 'Chưa có cây trong vườn';

  @override
  String get scanPlantToAdd => 'Quét cây để thêm vào vườn của bạn';

  @override
  String get careGuide => 'Hướng dẫn chăm sóc';

  @override
  String get all => 'Tất cả';

  @override
  String get watering => 'Tưới nước';

  @override
  String get light => 'Ánh sáng';

  @override
  String get maintenance => 'Bảo dưỡng';

  @override
  String get health => 'Sức khỏe';

  @override
  String get myGardenTitle => 'Vườn của tôi';

  @override
  String get startYourPlantCollection => 'Bắt đầu bộ sưu tập cây của bạn';

  @override
  String get searchPlants => 'Tìm kiếm cây...';

  @override
  String get indoor => 'Trong nhà';

  @override
  String get outdoor => 'Ngoài trời';

  @override
  String plants(int count) {
    return '$count cây';
  }

  @override
  String get yourGardenAwaits => 'Vườn đang chờ bạn';

  @override
  String get scanFirstPlant =>
      'Quét cây đầu tiên để bắt đầu xây dựng\nbộ sưu tập cây cá nhân của bạn';

  @override
  String get addReminder => 'Thêm nhắc nhở';

  @override
  String get plant => 'Cây';

  @override
  String get selectPlant => 'Chọn cây';

  @override
  String get remindMeAbout => 'Nhắc tôi về';

  @override
  String get repeat => 'Lặp lại';

  @override
  String get date => 'Ngày';

  @override
  String get time => 'Giờ';

  @override
  String get setReminder => 'Đặt nhắc nhở';

  @override
  String get once => 'Một lần';

  @override
  String get daily => 'Hàng ngày';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get fertilizing => 'Bón phân';

  @override
  String get noRemindersForDay => 'Không có nhắc nhở cho ngày này';

  @override
  String get tapAddReminder => 'Nhấn \"Thêm nhắc nhở\" để tạo mới';

  @override
  String tasks(int count) {
    return '$count nhiệm vụ';
  }

  @override
  String get searchReminders => 'Tìm nhắc nhở';

  @override
  String get enterPlantName => 'Nhập tên cây...';

  @override
  String get cancel => 'Hủy';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get upgradeToPro => 'Nâng cấp Pro';

  @override
  String get upgradeDescription =>
      'Nhận diện nhiều loại cây và chẩn đoán tình trạng cây';

  @override
  String get upgradeNow => 'Nâng cấp ngay';

  @override
  String get manageGarden => 'Quản lý vườn';

  @override
  String get general => 'Chung';

  @override
  String get security => 'Bảo mật';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get reminderNotification => 'Thông báo nhắc nhở';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get aboutUs => 'Về chúng tôi';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get hindi => 'Tiếng Hindi';

  @override
  String get portuguese => 'Tiếng Bồ Đào Nha';

  @override
  String get spanish => 'Tiếng Tây Ban Nha';

  @override
  String get indonesian => 'Tiếng Indonesia';

  @override
  String get korean => 'Tiếng Hàn';

  @override
  String get plantIdentification => 'Nhận diện cây';

  @override
  String get analyzingPlant => 'Đang phân tích cây...';

  @override
  String get poweredByGemini => 'Được hỗ trợ bởi Gemini 2.5 Flash';

  @override
  String possibleMatches(int count) {
    return '$count kết quả phù hợp';
  }

  @override
  String get noPlantsIdentified => 'Không nhận diện được cây';

  @override
  String get tryClearerPhoto => 'Thử chụp ảnh rõ hơn';

  @override
  String get confidence => 'Độ tin cậy';

  @override
  String get bestMatch => 'Phù hợp nhất';

  @override
  String get addToGarden => 'Thêm vào vườn';

  @override
  String plantAddedToGarden(String name) {
    return 'Đã thêm $name vào vườn!';
  }

  @override
  String get view => 'Xem';

  @override
  String get alreadyInGarden => 'Cây này đã có trong vườn của bạn!';

  @override
  String get fetchingCareInfo => 'Đang lấy thông tin chăm sóc...';

  @override
  String get diagnosisReport => 'Báo cáo chẩn đoán';

  @override
  String get healthStatus => 'Tình trạng sức khỏe';

  @override
  String get identifiedIssues => 'Vấn đề phát hiện';

  @override
  String get careSuggestions => 'Gợi ý chăm sóc';

  @override
  String get severity => 'Mức độ nghiêm trọng';

  @override
  String get contactUs => 'Liên hệ';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get followUs => 'Theo dõi chúng tôi';

  @override
  String version(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get allRightsReserved => 'Đã đăng ký bản quyền.';

  @override
  String get error => 'Lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get loading => 'Đang tải...';

  @override
  String get retry => 'Thử lại';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get share => 'Chia sẻ';

  @override
  String get close => 'Đóng';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get noPlantsFound => 'Không tìm thấy cây';

  @override
  String get addedToFavorites => 'Đã thêm vào yêu thích!';

  @override
  String get proTips => 'Mẹo hay';

  @override
  String get quickTips => 'Mẹo nhanh';

  @override
  String get overview => 'Tổng quan';

  @override
  String get careInstructions => 'Hướng dẫn chăm sóc';
}
