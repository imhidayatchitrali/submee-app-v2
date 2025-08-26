import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/property.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../generated/l10n.dart';
import '../utils/functions.dart';
import 'full_screen_gallery.dart';
import 'network_image.dart';
import 'property_amenity_tile.dart';

class PropertyCard extends HookWidget {
  const PropertyCard({
    super.key,
    required this.property,
  });
  final Property property;
  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurStyle: BlurStyle.inner,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image with price and dots
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    useSafeArea: false,
                    builder: (context) => FullscreenGalleryModal(
                      photos: property.photos,
                      initialIndex: currentIndex.value,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: PageView.builder(
                        itemCount: property.photos.length,
                        onPageChanged: (index) {
                          currentIndex.value = index;
                        },
                        itemBuilder: (context, index) => NetworkImageWithFallback.property(
                          imageUrl: property.photos[index],
                          isCircle: false,
                          size: double.infinity,
                        ),
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
                        '\$${property.price}',
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
                    property.photos.length,
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
                '${property.city}, ${property.country}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: [
                // Host info
                Row(
                  spacing: 16,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      decoration: property.hostPhoto != null
                          ? BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF317DC9),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            )
                          : null,
                      child: NetworkImageWithFallback.profile(
                        imageUrl: property.hostPhoto,
                        isCircle: true,
                        size: 40,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.hostName ?? 'N/A',
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

                // Amenities grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  childAspectRatio: 4,
                  children: [
                    // Show up to 6 amenities
                    ...property.items.take(6).map(
                          (item) => AmenityTile(
                            icon: item.icon,
                            text: getDatabaseItemNameTranslation(item.name, locale),
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
