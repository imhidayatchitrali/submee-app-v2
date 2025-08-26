class AppVersion {
  AppVersion({
    required this.version,
    required this.buildNumber,
    required this.environment,
    required this.requiredUpdate,
    required this.message,
    required this.downloadUrl,
  });
  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
        version: json['version'] as String,
        buildNumber: json['build_number'] as int,
        environment: json['environment'] as String,
        requiredUpdate: json['required_update'] as bool,
        message: json['message'] as String?,
        downloadUrl: json['download_url'] as String,
      );

  final String version;
  final int buildNumber;
  final String environment;
  final bool requiredUpdate;
  final String? message;
  final String downloadUrl;
}
