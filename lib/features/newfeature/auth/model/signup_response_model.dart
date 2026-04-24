class SignupResponseData {
  final String accessToken;
  final String? name;
  final String? email;
  final int? age;
  final bool? isApproved;
  final String? profileImage;

  SignupResponseData({
    required this.accessToken,
    this.name,
    this.email,
    this.age,
    this.isApproved,
    this.profileImage,
  });

  factory SignupResponseData.fromJson(Map<String, dynamic> json) {
    return SignupResponseData(
      accessToken: json['accessToken']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? ''),
      isApproved: json['isApproved'] as bool?,
      profileImage: json['profileImage']?.toString(),
    );
  }
}
