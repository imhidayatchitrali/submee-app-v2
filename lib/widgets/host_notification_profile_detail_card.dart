import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/property.dart';
import 'package:submee/utils/functions.dart';

import '../generated/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/enum.dart';
import 'custom_svg_picture.dart';
import 'full_screen_gallery.dart';
import 'network_image.dart';
import 'profile_network_image.dart';

class HostNotificationProfileDetailCard extends HookWidget {
  const HostNotificationProfileDetailCard({
    Key? key,
    required this.value,
    required this.context,
    required this.onWithdraw,
    required this.onChat,
  }) : super(key: key);
  final PropertyRequested value;
  final VoidCallback onWithdraw;
  final VoidCallback onChat;
  final BuildContext context;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buttonStyle = Theme.of(context).filledButtonTheme.style;
    final currentIndex = useState(0);
    final locale = S.of(context);
    final size = MediaQuery.sizeOf(context);
    final primaryColor = Theme.of(context).primaryColor;
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
                      value.hostFirstName + ' ' + value.hostLastName,
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value.title,
                      style: textTheme.bodyLarge!.copyWith(
                        fontSize: 14,
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
          Text(
            value.description,
            style: textTheme.labelSmall!.copyWith(
              fontSize: 12,
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
          Row(
            spacing: 3,
            children: [
              CustomSvgPicture(
                'assets/icons/location.svg',
                color: primaryColor,
                height: 15,
              ),
              Text(
                value.location,
                style: textTheme.labelSmall!.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (value.status == RequestStatus.approved)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onChat();
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
            FilledButton(
              style: buttonStyle!.copyWith(
                backgroundColor: WidgetStateProperty.all(AppTheme.redColor),
                foregroundColor: WidgetStateProperty.all(Colors.black),
              ),
              onPressed: onWithdraw,
              child: Text(
                locale.withdraw_button,
              ),
            ),
        ],
      ),
    );
  }
}
