import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/providers/property_providers.dart';
import 'package:submee/widgets/custom_svg_picture.dart';
import 'package:submee/widgets/map_placeholder.dart';

import '../generated/l10n.dart';
import '../utils/functions.dart';
import 'network_image.dart';
import 'property_amenity_tile.dart';

class PropertyDetailsModal extends HookConsumerWidget {
  const PropertyDetailsModal({
    required this.id,
    required this.onClose,
    super.key,
  });

  final int id;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final propertyDetail = ref.watch(propertyDetailProvider(id));
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),

          // Content
          Expanded(
            child: propertyDetail.when(
              data: (details) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property images carousel
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: PageView.builder(
                                  itemCount: details.photos.length,
                                  onPageChanged: (index) {
                                    currentIndex.value = index;
                                  },
                                  itemBuilder: (context, index) =>
                                      NetworkImageWithFallback.property(
                                    imageUrl: details.photos[index],
                                    isCircle: false,
                                    size: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '\$${details.price}',
                                    style: textTheme.labelSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    ' / ${locale.day}',
                                    style: textTheme.labelSmall!.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
                                details.photos.length,
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
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomSvgPicture(
                            'assets/icons/location.svg',
                            color: primaryColor,
                            height: 15,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${details.city}, ${details.country}',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          spacing: 20,
                          children: [
                            // Host info
                            Row(
                              children: [
                                Container(
                                  decoration: details.hostPhoto != null
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: primaryColor,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(50),
                                        )
                                      : null,
                                  child: NetworkImageWithFallback.profile(
                                    imageUrl: details.hostPhoto,
                                    isCircle: true,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      details.hostName ?? 'N/A',
                                      style: textTheme.labelLarge,
                                    ),
                                    Row(
                                      children: [
                                        const CustomSvgPicture(
                                          'assets/icons/star.svg',
                                          height: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.4',
                                          style: textTheme.bodyMedium!.copyWith(
                                            color: const Color(0xFFFFC107),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' (25)',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Text(
                              details.description,
                              style: textTheme.labelSmall!.copyWith(
                                color: const Color(0xFF5C5C5C),
                              ),
                            ),
                            // Amenities grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              childAspectRatio: 4,
                              children: details.items
                                  .map(
                                    (item) => AmenityTile(
                                      icon: item.icon,
                                      text: getDatabaseItemNameTranslation(item.name, locale),
                                      color: const Color(0xFF5C5C5C),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      // Property details
                      Text(
                        locale.location_placeholder,
                        style: textTheme.headlineSmall,
                      ),
                      MapPlaceholder(
                        location: details.location,
                      ),
                      Text(
                        '${details.location.city}, ${details.location.country}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5C5C5C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
