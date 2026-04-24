class LoginResponseData {
  final String accessToken;

  LoginResponseData({required this.accessToken});

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      accessToken: json['accessToken']?.toString() ?? '',
    );
  }
}
