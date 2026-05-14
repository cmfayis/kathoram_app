class RecentCallItem {
  final String id;
  final String caller;
  final int duration;
  final String status;
  final int createdAt;
  final RecentCallerDetails callerDetails;

  RecentCallItem({
    required this.id,
    required this.caller,
    required this.duration,
    required this.status,
    required this.createdAt,
    required this.callerDetails,
  });

  factory RecentCallItem.fromJson(Map<String, dynamic> json) {
    return RecentCallItem(
      id: json['_id']?.toString() ?? '',
      caller: json['caller']?.toString() ?? '',
      duration: json['duration'] is int ? json['duration'] as int : 0,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] is int ? json['createdAt'] as int : 0,
      callerDetails: RecentCallerDetails.fromJson(
        json['callerDetails'] is Map<String, dynamic>
            ? json['callerDetails'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class RecentCallerDetails {
  final String name;
  final String mobileNumber;
  final String email;

  RecentCallerDetails({
    required this.name,
    required this.mobileNumber,
    required this.email,
  });

  factory RecentCallerDetails.fromJson(Map<String, dynamic> json) {
    return RecentCallerDetails(
      name: json['name']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
