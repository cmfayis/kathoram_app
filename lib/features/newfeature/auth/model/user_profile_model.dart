class UserProfileData {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String profileImage;
  final bool isApproved;

  UserProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.isApproved,
    this.age,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? ''),
      profileImage: json['profileImage']?.toString() ?? '',
      isApproved: json['isApproved'] == true,
    );
  }
}
