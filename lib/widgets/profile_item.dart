import 'package:flutter/material.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../generated/l10n.dart';
import 'network_image.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    required this.title,
    this.asset,
    this.textColor = Colors.black,
    this.useArrow = true,
    this.addVerify = false,
    this.onTap,
    this.imageUrl,
    super.key,
  });
  final String title;
  final String? asset;
  final String? imageUrl;
  final Color? textColor;
  final bool useArrow;
  final bool addVerify;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                if (imageUrl != null)
                  NetworkImageWithFallback.profile(
                    imageUrl: imageUrl,
                    isCircle: true,
                    size: 24,
                  ),
                if (asset != null && imageUrl == null) CustomSvgPicture('assets/icons/$asset.svg'),
                Text(
                  title.capitalize(),
                  style: textTheme.bodyLarge!.copyWith(color: textColor),
                ),
              ],
            ),
            if (addVerify)
              Chip(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: primaryColor,
                    width: 1,
                  ),
                ),
                label: Text(
                  locale.verify,
                  style: textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: primaryColor,
              ),
            if (useArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}
