import 'package:flutter/material.dart';
import 'package:submee/utils/enum.dart';

import 'profile_network_image.dart';

class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback.property({
    super.key,
    required this.imageUrl,
    this.isCircle = false,
    this.size = 60,
  })  : height = null,
        iconSize = null,
        type = ImageType.property,
        width = null;
  const NetworkImageWithFallback.sublet({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
  })  : size = null,
        iconSize = null,
        type = ImageType.sublet,
        isCircle = false;
  const NetworkImageWithFallback.profile({
    super.key,
    required this.imageUrl,
    this.isCircle = false,
    this.size = 60,
  })  : height = null,
        iconSize = 40,
        type = ImageType.profile,
        width = null;
  const NetworkImageWithFallback.full({
    super.key,
    required this.imageUrl,
    this.isCircle = false,
    this.size = double.infinity,
  })  : height = null,
        iconSize = null,
        type = ImageType.full,
        width = null;

  final String? imageUrl;
  final bool isCircle;
  final double? size;
  final double? iconSize;
  final double? height;
  final double? width;
  final ImageType type;

  @override
  Widget build(BuildContext context) {
    final sizePage = MediaQuery.sizeOf(context);
    final iconSizeFixed = iconSize ??
        (type == ImageType.profile ? sizePage.height * 0.5 * 0.5 : sizePage.height * 0.5);
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CustomAvatar(
        size: size ?? sizePage.height * 0.5,
        iconSize: iconSizeFixed,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(isCircle ? 50 : 10),
      child: ProfileNetworkImage(
        imageUrl: imageUrl!,
        height: height,
        width: width,
        size: size,
      ),
    );
  }
}

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({
    super.key,
    required this.size,
    this.iconSize,
  });
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.person,
        size: iconSize ?? 30,
      ),
    );
  }
}
