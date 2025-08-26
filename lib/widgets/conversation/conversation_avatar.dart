import 'package:flutter/material.dart';

import '../profile_network_image.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
  });
  final String? avatarUrl;
  final String name;
  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildInitialsAvatar(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ProfileNetworkImage(
        imageUrl: avatarUrl!,
        size: 50,
        errorWidget: _buildInitialsAvatar(context),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final initials = name.isNotEmpty ? name.split(' ').take(2).map((e) => e[0]).join() : '?';
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
