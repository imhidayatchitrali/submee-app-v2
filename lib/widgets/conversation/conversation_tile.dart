import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/widgets/conversation/conversation_avatar.dart';

import '../../theme/app_theme.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    Key? key,
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.hasUnread,
    required this.unreadCount,
  }) : super(key: key);
  final int conversationId;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final bool hasUnread;
  final int unreadCount;
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () {
        context.push('/chat/$conversationId');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // User Avatar or Initials
            Stack(
              clipBehavior: Clip.none,
              children: [
                ConversationAvatar(
                  avatarUrl: avatarUrl,
                  name: name,
                ),
                if (hasUnread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.subletColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.capitalize(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Unread message count
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
