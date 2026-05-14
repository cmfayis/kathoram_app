class UserProfileData {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String profileImage;
  final bool isApproved;
  final String status;
  final String timezone;
  final StaffCoins staffCoins;

  UserProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.isApproved,
    this.age,
    this.status = 'offline',
    this.timezone = '',
    StaffCoins? staffCoins,
  }) : staffCoins = staffCoins ?? StaffCoins.empty();

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
      status: json['status']?.toString() ?? 'offline',
      timezone: json['timezone']?.toString() ?? '',
      staffCoins: json['staffCoins'] is Map<String, dynamic>
          ? StaffCoins.fromJson(json['staffCoins'] as Map<String, dynamic>)
          : StaffCoins.empty(),
    );
  }
}

class StaffCoins {
  final double dayCoins;
  final double nightCoins;

  StaffCoins({required this.dayCoins, required this.nightCoins});

  factory StaffCoins.empty() => StaffCoins(dayCoins: 0, nightCoins: 0);

  factory StaffCoins.fromJson(Map<String, dynamic> json) {
    return StaffCoins(
      dayCoins: _toDouble(json['dayCoins']),
      nightCoins: _toDouble(json['nightCoins']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
