import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/user.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/utils/functions.dart';

import '../generated/l10n.dart';
import '../utils/enum.dart';
import 'custom_svg_picture.dart';
import 'full_screen_gallery.dart';
import 'network_image.dart';
import 'profile_network_image.dart';

class UserNotificationProfileDetailCard extends HookWidget {
  const UserNotificationProfileDetailCard({
    Key? key,
    required this.value,
    required this.context,
    required this.onDecline,
    required this.onApprove,
    required this.onChatPressed,
  }) : super(key: key);
  final UserRequested value;
  final VoidCallback onDecline;
  final VoidCallback onApprove;
  final BuildContext context;
  final VoidCallback onChatPressed;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buttonStyle = Theme.of(context).filledButtonTheme.style;
    final locale = S.of(context);
    final size = MediaQuery.sizeOf(context);
    final currentIndex = useState(0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Text(
                  locale.details,
                  style: textTheme.labelLarge,
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ProfileNetworkImage(
                  imageUrl: value.photos[0],
                  size: 55,
                ),
              ),
              // Profile Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.firstName.capitalize() + ' ' + value.lastName.capitalize(),
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '34y',
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
          Text(
            value.bio,
            style: textTheme.bodyLarge!.copyWith(
              fontSize: 14,
            ),
          ),
          Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: size.height * 0.25,
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      useSafeArea: false,
                      builder: (context) => FullscreenGalleryModal(
                        photos: value.photos,
                        initialIndex: currentIndex.value,
                      ),
                    );
                  },
                  child: Container(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PageView.builder(
                          itemCount: value.photos.length,
                          onPageChanged: (index) {
                            currentIndex.value = index;
                          },
                          itemBuilder: (context, index) => NetworkImageWithFallback.profile(
                            imageUrl: value.photos[index],
                            isCircle: false,
                            size: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    value.photos.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentIndex.value
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (value.status == RequestStatus.approved)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onChatPressed();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  CustomSvgPicture(
                    'assets/icons/chat.svg',
                    color: Colors.white,
                  ),
                  Text(
                    'Chat',
                  ),
                ],
              ),
            ),
          if (value.status == RequestStatus.pending)
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: buttonStyle!.copyWith(
                      foregroundColor: WidgetStateProperty.all(
                        const Color(0xFF949494),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.white,
                      ),
                    ),
                    onPressed: onDecline,
                    child: Text(locale.decline),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onApprove();
                    },
                    child: Text(locale.approve),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
