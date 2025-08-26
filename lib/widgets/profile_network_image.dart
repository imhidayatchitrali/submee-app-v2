import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

import 'network_image.dart';

class ProfileNetworkImage extends StatelessWidget {
  const ProfileNetworkImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.width,
    this.height,
    this.errorWidget,
  });
  final String imageUrl;
  final double? size;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    // Check if the image is an AVIF format
    final bool isAvif = imageUrl.toLowerCase().endsWith('.avif');

    // Use the appropriate widget based on image format
    if (isAvif) {
      return CachedNetworkAvifImage(
        imageUrl,
        width: size ?? width,
        height: size ?? height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, __) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: child,
        ),
        frameBuilder: (context, child, _, __) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: child,
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading AVIF image: $error\n$stackTrace');
          return errorWidget ??
              CustomAvatar(
                size: size ?? 60,
              );
        },
      );
    } else {
      // Use regular CachedNetworkImage for non-AVIF formats
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: size ?? width,
        height: size ?? height,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 500),
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: const Center(
            child: AnimatedOpacity(
              opacity: 0.3,
              duration: Duration(milliseconds: 500),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        errorWidget: (context, error, stackTrace) {
          debugPrint('Error loading image: $error\n$stackTrace');
          return errorWidget ??
              CustomAvatar(
                size: size ?? 60,
              );
        },
        cacheKey: imageUrl,
      );
    }
  }
}
