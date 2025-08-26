import 'package:flutter/material.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/widgets/custom_svg_picture.dart';
import 'package:submee/widgets/network_image.dart';

import '../generated/l10n.dart';
import '../utils/preferences.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.onProfileTap,
    required this.notificationTap,
    this.title,
  });
  final String? image;
  final String? name;
  final String? location;
  final VoidCallback onProfileTap;
  final String? title;
  final VoidCallback notificationTap;
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Profile image and text
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: NetworkImageWithFallback.profile(
              imageUrl: image,
            ),
          ),
        ),
        if (title == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${locale.hi}, ${name?.capitalize().split(' ').first}',
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
              if (!Preferences.isHost)
                Row(
                  children: [
                    const CustomSvgPicture(
                      'assets/icons/location.svg',
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      location ?? 'No Location',
                      style: textTheme.displaySmall!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        if (title != null)
          Text(
            title!,
            style: textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
        // Right side - Notification bell
        InkWell(
          onTap: notificationTap,
          child: Stack(
            children: [
              const CustomSvgPicture('assets/icons/bell-notification-dot.svg'),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
