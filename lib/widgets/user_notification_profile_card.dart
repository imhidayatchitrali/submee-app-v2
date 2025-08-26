import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/models/user.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/utils/functions.dart';

import '../generated/l10n.dart';
import 'banners/modal_wrapper.dart';
import 'custom_svg_picture.dart';
import 'profile_network_image.dart';
import 'user_notification_profile_detail_card.dart';

class UserNotificationProfileCard extends StatelessWidget {
  const UserNotificationProfileCard({
    Key? key,
    required this.value,
    required this.onDecline,
    required this.onApprove,
    required this.context,
  }) : super(key: key);
  final UserRequested value;
  final VoidCallback onDecline;
  final VoidCallback onApprove;
  final BuildContext context;
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final locale = S.of(context);
    final buttonStyle = Theme.of(context).elevatedButtonTheme.style;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        showCustomModal(
          context: context,
          contentPadding: const EdgeInsets.all(0),
          child: UserNotificationProfileDetailCard(
            value: value,
            context: context,
            onDecline: onDecline,
            onApprove: onApprove,
            onChatPressed: () {
              if (value.conversationId != null) {
                context.push('/chat/${value.conversationId}');
                return;
              }
              context.push('/chat/new/${value.propertyId}');
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ProfileNetworkImage(
                imageUrl: value.photos[0],
                size: 80,
              ),
            ),
            // Profile Information
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value.firstName.capitalize() + ' ' + value.lastName.capitalize(),
                              style: textTheme.labelMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              value.propertyTitle,
                              style: textTheme.bodyLarge!.copyWith(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              value.location,
                              style: textTheme.labelSmall!.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatDateString(value.createdAt),
                        style: textTheme.labelSmall!.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (value.status != RequestStatus.approved)
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: buttonStyle!.copyWith(
                              foregroundColor: WidgetStateProperty.all(
                                const Color(0xFF949494),
                              ),
                            ),
                            onPressed: onDecline,
                            child: Text(locale.decline),
                          ),
                        ),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              onApprove();
                            },
                            child: Text(locale.approve),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (value.status == RequestStatus.approved)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvgPicture(
                    'assets/icons/chat.svg',
                    color: primaryColor,
                    height: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
