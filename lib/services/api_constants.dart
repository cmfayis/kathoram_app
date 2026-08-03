class ApiConstants {
  // static const String baseUrl = 'http://13.206.185.19/';
  // static const String baseUrl = 'https://admin.kathoram.coresports.co.in/';
  static const baseUrl = 'http://3.7.254.77/';

  static String refreshToken = "";

  // Common Base Path
  static const String staffBase = 'api/v1/staff/';

  // Auth APIs
  static const String login = '${staffBase}login';
  static const String signup = '${staffBase}signup';
  static const String isLogin = '${staffBase}is-login';
  static const String logout = '${staffBase}logout';
  static const String deleteAccount = '${staffBase}delete';
  static const String updateProfile = '${staffBase}update';

  // File Upload APIs
  static const String fileUpload = '${staffBase}file/upload';
  static const String uploadFile = fileUpload;

  // Call APIs
  static const String callHistory = '${staffBase}call-history';
  static const String recentCalls = '${staffBase}recent-calls';

  // App version / maintenance check
  static const String currentVersion = 'api/v1/user/current/version';
}
