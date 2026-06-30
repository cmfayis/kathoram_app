// ignore_for_file: file_names

/// Parses the `data` object returned by the `api/v1/user/current/version`
/// endpoint. The relevant payload looks like:
///
/// {
///   "version": [
///     { "name": "staff-android", "forceUpdate": false, "active": true,
///       "version": "1.0.3", "redirectUrl": "https://..." },
///     { "name": "maintenanceBreak", "active": false,
///       "message": "App is under maintenance ..." }
///   ]
/// }
class VersionControlData {
  final List<VersionInfo> version;

  VersionControlData({this.version = const []});

  factory VersionControlData.fromJson(Map<String, dynamic> json) {
    final list = json['version'];
    return VersionControlData(
      version: list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(VersionInfo.fromJson)
              .toList()
          : const [],
    );
  }
}

class VersionInfo {
  final String? id;
  final String? name;
  final bool active;
  final bool forceUpdate;
  final String? version;
  final String? redirectUrl;
  final String? message;
  final int? createdAt;

  VersionInfo({
    this.id,
    this.name,
    this.active = false,
    this.forceUpdate = false,
    this.version,
    this.redirectUrl,
    this.message,
    this.createdAt,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      active: json['active'] == true,
      forceUpdate: json['forceUpdate'] == true,
      version: json['version']?.toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt'] is int ? json['createdAt'] as int : null,
    );
  }
}
