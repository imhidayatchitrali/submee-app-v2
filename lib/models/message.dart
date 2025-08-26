import '../utils/preferences.dart';

class MessageModel {
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.readAt,
    required this.isSender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Get current user ID from auth service
    final currentUserId = Preferences.userId;

    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      // Parse date strings with proper handling of UTC format
      sentAt: _parseDateTime(json['sent_at']),
      readAt: json['read_at'] != null ? _parseDateTime(json['read_at']) : null,
      isSender: json['sender_id'] == currentUserId,
    );
  }
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isSender;

  // Helper method to parse date strings from the backend
  static DateTime _parseDateTime(String dateString) {
    // Handle ISO 8601 format (including the 'Z' for UTC)
    if (dateString.endsWith('Z')) {
      return DateTime.parse(dateString);
    }

    // Handle date format like "2025-05-09 15:53:06.100"
    try {
      return DateTime.parse(dateString + 'Z'); // Add 'Z' to indicate UTC
    } catch (e) {
      // Fallback for any other format
      return DateTime.parse(dateString);
    }
  }
}
