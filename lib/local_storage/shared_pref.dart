import 'package:shared_preferences/shared_preferences.dart';

class MySharedPref {
  // prevent making instance
  MySharedPref._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _fcmTokenKey = 'fcm_token';
  static const String _isLoggedIn = 'is_logged_in';
  static const String _refreshToken = 'refresh_token';
  static const String _isForgotPassword = 'isForgotPassword';
  static const String _authToken = 'auth_token';
  static const String _currencyType = 'currencyType';
  static const String _mobileNumber = 'mobileNumber';
  static const String _userEmail = 'userEmail';
  static const String _temporaryToken = 'temporaryToken';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setLoggedInStatus(bool isLoggedIn) =>
      _sharedPreferences.setBool(_isLoggedIn, isLoggedIn);

  /// get if the current theme type is light
  static bool getLoggedInStatus() =>
      _sharedPreferences.getBool(_isLoggedIn) ?? false;

  /// set theme current type as light theme
  static Future<void> setForgotPasswordStatus(bool isLoggedIn) =>
      _sharedPreferences.setBool(_isForgotPassword, isLoggedIn);

  /// get if the current theme type is light
  static bool getForgotPasswordStatus() =>
      _sharedPreferences.getBool(_isForgotPassword) ?? false;

  /// save generated fcm token
  static Future<void> setFcmToken(String token) =>
      _sharedPreferences.setString(_fcmTokenKey, token);

  /// get authorization token
  static String? getFcmToken() => _sharedPreferences.getString(_fcmTokenKey);

  static Future<void> setMobileNumber(String mobileNumber) =>
      _sharedPreferences.setString(_mobileNumber, mobileNumber);

  static String? getMobileNumber() =>
      _sharedPreferences.getString(_mobileNumber);

  static Future<void> setUserEmail(String email) =>
      _sharedPreferences.setString(_userEmail, email);

  static String? getUserEmail() => _sharedPreferences.getString(_userEmail);

  /// save generated refresh token
  static Future<void> setRefreshToken(String token) =>
      _sharedPreferences.setString(_refreshToken, token);

  ///Set Both Auth and refresh Tojen
  static setTokens(String authToken, String refreshToken) async {
    await setAuthToken(authToken);
    await setRefreshToken(refreshToken);
    _sharedPreferences.setBool(_isLoggedIn, true);
  }

  /// get refresh token
  static String? getRefreshToken() =>
      _sharedPreferences.getString(_refreshToken);

  /// save generated auth token
  static Future<void> setAuthToken(String token) =>
      _sharedPreferences.setString(_authToken, token);

  /// get authorization token
  static String? getAuthToken() => _sharedPreferences.getString(_authToken);

  /// save generated fcm token
  static Future<void> setCurrencyType(String text) =>
      _sharedPreferences.setString(_currencyType, text);

  /// get authorization token
  static String getCurrencyType() =>
      _sharedPreferences.getString(_currencyType) ?? "\$";

  /// set theme current type as light theme
  static Future<void> setTemporaryTokenStatus(bool isLoggedIn) =>
      _sharedPreferences.setBool(_temporaryToken, isLoggedIn);

  /// get if the current theme type is light
  static bool getTemporaryTokenStatus() {
    return _sharedPreferences.getBool(_temporaryToken) ?? false;
  }

  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();
}
