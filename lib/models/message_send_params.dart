class MessageSendParams {
  // Optional - might be needed for new conversations if host is sending

  MessageSendParams({
    this.conversationId,
    required this.content,
    this.propertyId,
    this.otherUserId,
  }) {
    // Validate that we have either conversationId OR propertyId
    if (conversationId == null && propertyId == null) {
      throw ArgumentError('Either conversationId or propertyId must be provided');
    }
  }
  final int? conversationId; // Optional - can be null for new conversations
  final String content;
  final int? propertyId; // Optional - required for new conversations
  final int? otherUserId;
}
