class HelperModal {
  HelperModal({
    required this.id,
    required this.code,
    required this.routePath,
    required this.imageUrl,
    required this.description,
    required this.buttonText,
    this.isActive = true,
  });

  factory HelperModal.fromJson(Map<String, dynamic> json) {
    return HelperModal(
      id: json['id'],
      code: json['code'],
      routePath: json['route_path'],
      imageUrl: json['image_url'],
      description: json['description'],
      buttonText: json['button_text'],
      isActive: json['is_active'] ?? true,
    );
  }
  final int id;
  final String code;
  final String routePath;
  final String imageUrl;
  final String description;
  final String buttonText;
  final bool isActive;
}
