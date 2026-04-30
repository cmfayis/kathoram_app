class CallHistoryItem {
  final String id;
  final String caller;
  final String receiver;
  final int startTime;
  final int? endedAt;
  final int duration;
  final int coinsUsed;
  final String status;
  final String disconnectReason;
  final CallerDetails callerDetails;

  CallHistoryItem({
    required this.id,
    required this.caller,
    required this.receiver,
    required this.startTime,
    this.endedAt,
    required this.duration,
    required this.coinsUsed,
    required this.status,
    required this.disconnectReason,
    required this.callerDetails,
  });

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      id: json['_id']?.toString() ?? '',
      caller: json['caller']?.toString() ?? '',
      receiver: json['receiver']?.toString() ?? '',
      startTime: json['startTime'] is int ? json['startTime'] as int : 0,
      endedAt: json['endedAt'] is int ? json['endedAt'] as int : null,
      duration: json['duration'] is int ? json['duration'] as int : 0,
      coinsUsed: json['coinsUsed'] is int ? json['coinsUsed'] as int : 0,
      status: json['status']?.toString() ?? '',
      disconnectReason: json['disconnectReason']?.toString() ?? '',
      callerDetails: CallerDetails.fromJson(
        json['callerDetails'] is Map<String, dynamic>
            ? json['callerDetails'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class CallerDetails {
  final String name;
  final String mobileNumber;

  CallerDetails({
    required this.name,
    required this.mobileNumber,
  });

  factory CallerDetails.fromJson(Map<String, dynamic> json) {
    return CallerDetails(
      name: json['name']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
    );
  }
}

class CallHistoryPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CallHistoryPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory CallHistoryPagination.fromJson(Map<String, dynamic> json) {
    return CallHistoryPagination(
      total: json['total'] is int ? json['total'] as int : 0,
      page: json['page'] is int ? json['page'] as int : 1,
      pageSize: json['pageSize'] is int ? json['pageSize'] as int : 10,
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : 1,
    );
  }
}
