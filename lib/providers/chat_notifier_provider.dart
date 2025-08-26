// message_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../services/conversation_service.dart';

// Define the state structure
class ChatState {
  ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.messages = const [],
    this.conversationId,
    this.isNewConversation = false,
  });
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<MessageModel> messages;
  final int? conversationId;
  final bool isNewConversation;

  // Create a copy with updated fields
  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    String? error,
    List<MessageModel>? messages,
    int? conversationId,
    bool? isNewConversation,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error, // Pass null to clear error
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      isNewConversation: isNewConversation ?? this.isNewConversation,
    );
  }
}

// Define the notifier
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.ref, {this.initialConversationId, this.propertyId, this.otherUserId})
      : super(ChatState(conversationId: initialConversationId)) {
    // Start polling if we have a conversation ID
    if (initialConversationId != null) {
      _startPolling();
    }
  }

  final Ref ref;
  final int? initialConversationId;
  final int? propertyId;
  final int? otherUserId;

  Timer? _pollingTimer;

  // Start polling for messages
  void _startPolling() {
    // Cancel any existing timer
    _pollingTimer?.cancel();

    // Initial load
    fetchMessages();

    // Setup polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMessages();
    });
  }

  // Fetch messages
  Future<void> fetchMessages() async {
    // Skip if no conversationId available or already loading
    if (state.conversationId == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(conversationService);
      final messages = await service.getMessages(state.conversationId!);
      state = state.copyWith(
        isLoading: false,
        messages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages: $e',
      );
    }
  }

  // Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true);
    try {
      final service = ref.read(conversationService);

      final data = await service.sendMessage(
        conversationId: state.conversationId,
        content: content,
        propertyId: propertyId,
        otherUserId: otherUserId,
      );

      // Get the conversation ID from response
      final conversationId = data['message']['conversation_id'] as int;
      final isNewConversation = state.conversationId == null;

      // Update state with new conversation ID if needed
      state = state.copyWith(
        isSending: false,
        conversationId: conversationId,
        isNewConversation: isNewConversation,
      );

      // Start polling if this is a new conversation
      if (isNewConversation) {
        _startPolling();
      } else {
        // If not new, just refresh messages
        fetchMessages();
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send message: $e',
      );
    }
  }

  // Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

// Provider factory that creates a ChatNotifier with parameters
final chatProvider =
    StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, ChatParams>((ref, params) {
  return ChatNotifier(
    ref,
    initialConversationId: params.conversationId,
    propertyId: params.propertyId,
    otherUserId: params.otherUserId,
  );
});

// Parameters class for the provider
class ChatParams {
  ChatParams({
    this.conversationId,
    this.propertyId,
    this.otherUserId,
  });
  final int? conversationId;
  final int? propertyId;
  final int? otherUserId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatParams &&
        other.conversationId == conversationId &&
        other.propertyId == propertyId &&
        other.otherUserId == otherUserId;
  }

  @override
  int get hashCode => conversationId.hashCode ^ propertyId.hashCode ^ otherUserId.hashCode;
}
