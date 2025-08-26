import 'package:flutter/material.dart';
import 'package:submee/utils/extension.dart';
import 'package:submee/widgets/network_image.dart';

class FavoriteItem extends StatelessWidget {
  const FavoriteItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.onTap,
    this.profileUrl,
  });
  final String imageUrl;
  final String? profileUrl;
  final String name;
  final String location;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryColor = Theme.of(context).primaryColorDark;
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 120,
                child: NetworkImageWithFallback.full(
                  imageUrl: imageUrl,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Icon(
                  Icons.favorite,
                  color: primaryColor,
                  size: 30,
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileUrl != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        width: 2,
                        color: secondaryColor,
                      ),
                    ),
                    child: NetworkImageWithFallback.profile(
                      imageUrl: profileUrl,
                      isCircle: true,
                      size: 40,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.capitalize(),
                        style: textTheme.labelMedium!.copyWith(
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        location,
                        style: textTheme.labelMedium!.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF949494),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
