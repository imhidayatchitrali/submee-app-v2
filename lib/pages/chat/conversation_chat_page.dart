import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/conversation_provider.dart';
import '../../widgets/conversation/conversation_tile.dart';

class ConversationChatPage extends ConsumerStatefulWidget {
  const ConversationChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationChatPage> createState() => _ConversationChatPageState();
}

class _ConversationChatPageState extends ConsumerState<ConversationChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the conversation list provider
    final conversationsAsync = ref.watch(listConversationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Conversation list with Riverpod AsyncValue
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Refresh the provider
                        ref.invalidate(listConversationProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (conversations) {
                // Filter conversations based on search query
                final filteredConversations = _searchQuery.isEmpty
                    ? conversations
                    : conversations.where((conversation) {
                        return conversation.otherUserFirstName
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            conversation.propertyTitle
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredConversations.isEmpty) {
                  return const Center(
                    child: Text('No conversations found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh the provider
                    ref.invalidate(listConversationProvider);
                  },
                  child: ListView.separated(
                    itemCount: filteredConversations.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 3, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      return ConversationTile(
                        conversationId: conversation.id,
                        name:
                            conversation.otherUserFirstName + ' ' + conversation.otherUserLastName,
                        lastMessage: conversation.lastMessage,
                        avatarUrl: conversation.otherUserPhoto,
                        hasUnread: conversation.hasUnread,
                        unreadCount: conversation.unreadCount,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
