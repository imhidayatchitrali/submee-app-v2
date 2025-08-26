import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/conversation.dart';

import '../models/user.dart';
import '../services/conversation_service.dart';

final listConversationProvider = StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final controller = StreamController<List<ConversationModel>>();
  bool isLoading = false;
  Timer? pollingTimer;

  // Function to load messages
  Future<void> loadConversations() async {
    if (isLoading) return;

    isLoading = true;
    try {
      final service = ref.read(conversationService);
      final messages = await service.getConversations();
      controller.add(messages);
    } catch (e) {
      controller.addError(e);
    } finally {
      isLoading = false;
    }
  }

  // Initial load
  loadConversations();

  // Setup polling
  pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    loadConversations();
  });

  // Return a cleanup function
  ref.onDispose(() {
    pollingTimer?.cancel();
    controller.close();
  });

  return controller.stream;
});

class UserChatParam extends Equatable {
  const UserChatParam({
    this.conversationId,
    this.propertyId,
  });

  final int? conversationId;
  final int? propertyId;

  @override
  List<Object?> get props => [
        conversationId,
        propertyId,
      ];
}

final otherUserChatProvider = FutureProvider.autoDispose.family<UserSwipeInfoChat, UserChatParam>(
  (ref, params) async {
    final service = ref.read(conversationService);
    final result = await service.getOtherUserConversation(params);
    return result;
  },
);
