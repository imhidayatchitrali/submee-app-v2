class ConversationModel {
  ConversationModel({
    required this.id,
    required this.otherUserFirstName,
    required this.otherUserLastName,
    required this.otherUserPhoto,
    required this.propertyTitle,
    required this.lastMessage,
    required this.hasUnread,
    required this.propertyId,
    required this.lastMessageTime,
    required this.otherUserId,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'],
      otherUserFirstName: json['other_user_first_name'],
      otherUserLastName: json['other_user_last_name'],
      otherUserId: json['other_user_id'],
      otherUserPhoto: json['other_user_photo'] ?? '',
      propertyTitle: json['property_title'],
      lastMessage: json['last_message'] ?? '',
      propertyId: json['property_id'],
      unreadCount: json['unread_count'] ?? 0,
      hasUnread: json['unread_count'] > 0,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
    );
  }
  final int id;
  final String otherUserFirstName;
  final String otherUserLastName;
  final int otherUserId;
  final int unreadCount;
  final String otherUserPhoto;
  final String propertyTitle;
  final int propertyId;
  final String lastMessage;
  final bool hasUnread;
  final DateTime lastMessageTime;
}
