import 'package:flutter/material.dart';
import 'package:submee/models/property_details.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, required this.location});
  final PropertyLocation location;
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () {
        launchMap(location);
      },
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/map_placeholder.png',
            ),
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const CustomSvgPicture(
                'assets/icons/house-simple.svg',
                height: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
