import 'package:flutter/material.dart';
import 'package:submee/models/property.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/banners/modal_wrapper.dart';

import '../generated/l10n.dart';
import '../theme/app_theme.dart';
import 'custom_svg_picture.dart';
import 'host_notification_profile_detail_card.dart';
import 'profile_network_image.dart';

class HostNotificationProfileCard extends StatelessWidget {
  const HostNotificationProfileCard({
    Key? key,
    required this.value,
    required this.onWithdraw,
    required this.onChat,
  }) : super(key: key);
  final PropertyRequested value;
  final VoidCallback onWithdraw;
  final VoidCallback onChat;
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final locale = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        showCustomModal(
          context: context,
          contentPadding: const EdgeInsets.all(0),
          child: HostNotificationProfileDetailCard(
            value: value,
            context: context,
            onChat: onChat,
            onWithdraw: onWithdraw,
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
                imageUrl: value.hostPhoto,
                size: 80,
              ),
            ),
            // Profile Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.hostFirstName.capitalize() + ' ' + value.hostLastName,
                    style: textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.title,
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
                  const SizedBox(height: 8),
                  Text(
                    formatDateString(value.createdAt),
                    style: textTheme.labelSmall!.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            if (value.status == RequestStatus.pending)
              InkWell(
                onTap: onWithdraw,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.redColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      locale.withdraw_button,
                      style: textTheme.labelSmall!.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            if (value.status == RequestStatus.approved)
              InkWell(
                onTap: onChat,
                child: Container(
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
              ),
          ],
        ),
      ),
    );
  }
}
