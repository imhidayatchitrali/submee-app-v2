import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:submee/models/message.dart';
import 'package:submee/providers/chat_notifier_provider.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/widgets/conversation/conversation_avatar.dart';

import '../../generated/l10n.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/conversation/message_bubble.dart';

class ConversationDetailPage extends HookConsumerWidget {
  const ConversationDetailPage({
    Key? key,
    this.conversationId,
    this.propertyId,
  }) : super(key: key);
  final int? conversationId;
  final int? propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get other user info
    final userSwipeData = ref.watch(
      otherUserChatProvider(
        UserChatParam(
          conversationId: conversationId,
          propertyId: propertyId,
        ),
      ),
    );

    // Watch the chat state
    final chatParams = useMemoized(
      () => ChatParams(
        conversationId: conversationId,
        propertyId: propertyId,
        otherUserId: userSwipeData.value?.id,
      ),
      [conversationId, propertyId, userSwipeData.value?.id],
    );

    final chatState = ref.watch(chatProvider(chatParams));
    final chatNotifier = ref.watch(chatProvider(chatParams).notifier);

    final _scrollController = useScrollController();
    final _messageController = useTextEditingController();
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);

    // Use for automatic scrolling to bottom when new messages arrive
    final _shouldScrollToBottom = useState(true);
    final _previousMessageCount = useRef<int>(0);

    // Update URL if this is a new conversation and we've got a conversationId
    useEffect(
      () {
        if (chatState.isNewConversation && chatState.conversationId != null) {
          // Only update URL, don't navigate
          // Example with GoRouter
          // GoRouter.of(context).replace('/chat/${chatState.conversationId}');

          // Or update the page title
          // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          //   statusBarColor: primaryColor,
          // ));
        }
        return null;
      },
      [chatState.isNewConversation, chatState.conversationId],
    );

    // Scroll to bottom when new messages arrive
    useEffect(
      () {
        if (!chatState.isLoading) {
          final messages = chatState.messages;

          // If we have more messages than before and we should scroll to bottom
          if (messages.length > _previousMessageCount.value && _shouldScrollToBottom.value) {
            // Use a post-frame callback to ensure the ListView has rendered
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          // Update previous message count
          _previousMessageCount.value = messages.length;
        }
        return null;
      },
      [chatState.messages, chatState.isLoading],
    );

    // Listen to scroll events to determine if we should auto-scroll
    useEffect(
      () {
        void listener() {
          // If we're near the bottom, enable auto-scrolling for new messages
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final currentScroll = _scrollController.offset;
            const threshold = 100.0; // px from bottom

            // If we're near the bottom, enable auto-scrolling
            _shouldScrollToBottom.value = (maxScroll - currentScroll) <= threshold;
          }
        }

        _scrollController.addListener(listener);
        return () => _scrollController.removeListener(listener);
      },
      [_scrollController],
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userSwipeData.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => const Text('Error loading conversation'),
                  data: (data) {
                    return Row(
                      children: [
                        ConversationAvatar(
                          name: data.firstName + ' ' + data.lastName,
                          avatarUrl: data.photo,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.firstName.capitalize() + ' ' + data.lastName,
                              style: textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              data.propertyTitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child: Stack(
              children: [
                // Error message if any
                if (chatState.error != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              chatState.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => chatNotifier.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Show loading indicator or messages
                if (chatState.isLoading && chatState.messages.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildMessagesList(
                    context,
                    chatState.messages,
                    _scrollController,
                    locale,
                    chatNotifier,
                    isRefreshing: chatState.isLoading,
                  ),
              ],
            ),
          ),

          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: locale.your_message,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) {
                        _sendMessage(
                          controller: _messageController,
                          chatNotifier: chatNotifier,
                        );
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {
                      _sendMessage(
                        controller: _messageController,
                        chatNotifier: chatNotifier,
                      );
                      FocusScope.of(context).unfocus();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: chatState.isSending
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage({
    required TextEditingController controller,
    required ChatNotifier chatNotifier,
  }) {
    final messageText = controller.text.trim();
    if (messageText.isEmpty) return;

    chatNotifier.sendMessage(messageText);
    controller.clear();
  }

  Widget _buildMessagesList(
    BuildContext context,
    List<MessageModel> messages,
    ScrollController scrollController,
    dynamic locale,
    ChatNotifier chatNotifier, {
    bool isRefreshing = false,
  }) {
    // Group messages by date
    final groupedMessages = _groupMessagesByDate(messages);

    return messages.isEmpty
        ? RefreshIndicator(
            onRefresh: () async {
              chatNotifier.fetchMessages();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(child: Text(locale.no_message_yet)),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              chatNotifier.fetchMessages();
            },
            child: Stack(
              children: [
                ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final entry = groupedMessages.entries.elementAt(index);
                    final date = entry.key;
                    final messagesForDate = entry.value;

                    return Column(
                      children: [
                        // Date separator
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Messages for this date
                        ...messagesForDate.map((message) {
                          return MessageBubble(
                            message: message,
                            isSender: message.isSender,
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
                if (isRefreshing)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          );
  }

  // Group messages by date for display with date separators
  Map<String, List<MessageModel>> _groupMessagesByDate(List<MessageModel> messages) {
    final groupedMessages = <String, List<MessageModel>>{};

    for (final message in messages) {
      final date = _formatMessageDate(message.sentAt);

      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }

      groupedMessages[date]!.add(message);
    }

    return groupedMessages;
  }

  String _formatMessageDate(DateTime date) {
    // Convert to local time zone from UTC if needed
    final localDate = date.isUtc ? date.toLocal() : date;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(localDate.year, localDate.month, localDate.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format date based on how far in the past it is
      final difference = today.difference(messageDate).inDays;

      if (difference < 7) {
        // Within the last week - show day of week
        return DateFormat('EEEE').format(localDate); // e.g., "Monday"
      } else if (localDate.year == now.year) {
        // This year - show day and month
        return DateFormat('MMM d').format(localDate); // e.g., "May 9"
      } else {
        // Different year - show day, month and year
        return DateFormat('MMM d, yyyy').format(localDate); // e.g., "May 9, 2025"
      }
    }
  }
}
