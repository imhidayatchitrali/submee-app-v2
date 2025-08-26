import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/property.dart';
import 'package:submee/utils/functions.dart';

import '../generated/l10n.dart';
import 'network_image.dart';

class PublishPlaceOnboardingPreview extends HookWidget {
  const PublishPlaceOnboardingPreview({
    super.key,
    required this.property,
  });
  final PropertyInput property;
  @override
  Widget build(BuildContext context) {
    final currentPage = useState(0);
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final locale = S.of(context);

    // Calculate total photos count
    final totalPhotos = property.currentPhotos.length + property.photos.length;

    return SingleChildScrollView(
      child: Column(
        spacing: 34,
        children: [
          Text(
            locale.preview_message,
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 250,
                          child: PageView.builder(
                            itemCount: totalPhotos,
                            onPageChanged: (index) {
                              currentPage.value = index;
                            },
                            itemBuilder: (context, index) {
                              // First show existing photos from DB
                              if (index < (property.currentPhotos.length)) {
                                return NetworkImageWithFallback.full(
                                  imageUrl: property.currentPhotos[index],
                                );
                              }
                              // Then show new photos (File objects)
                              else {
                                final fileIndex = index - (property.currentPhotos.length);
                                return Image.file(
                                  property.photos[fileIndex],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            totalPhotos,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPage.value == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDateRange(property.startDate, property.endDate),
                          style: textTheme.bodyMedium!.copyWith(
                            color: const Color(0xFF949494),
                          ),
                        ),
                        Text(
                          locale.listing_status_new.toUpperCase(),
                          style: textTheme.labelSmall!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      property.title,
                      style: textTheme.labelLarge!.copyWith(
                        fontSize: 19,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${property.price.ceil()} ',
                            style: textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: locale.price_per_night,
                            style: textTheme.bodyMedium!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
