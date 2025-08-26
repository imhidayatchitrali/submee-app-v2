import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:submee/widgets/custom_svg_picture.dart';
import 'package:submee/widgets/network_image.dart';

import '../generated/l10n.dart';
import '../models/sublet.dart';

class SubletCard extends StatelessWidget {
  const SubletCard({
    Key? key,
    required this.item,
  }) : super(key: key);
  final Sublet item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.5),
            blurStyle: BlurStyle.inner,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile image
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    height: size.height * 0.4,
                    child: PageView.builder(
                      itemCount: item.photos.length,
                      onPageChanged: (index) {},
                      itemBuilder: (context, index) => NetworkImageWithFallback.sublet(
                        imageUrl: item.photos[index],
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Bottom overlay with tags and user info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFC6C6C6).withValues(alpha: 0.8),
                          const Color(0xFFC6C6C6).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Single', 'Pet Friendly', 'Furnished']
                                .map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Name and age
                        Text(
                          '${item.firstName} ${item.lastName}, ${item.dob != null ? _calculateAge(item.dob!) : ''}',
                          style: textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        Row(
                          spacing: 7,
                          children: [
                            const CustomSvgPicture(
                              'assets/icons/search.svg',
                              height: 14,
                            ),
                            Expanded(
                              child: Text(
                                item.location,
                                style: textTheme.labelSmall!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: primaryColor,
                ),
              ),
              Text(
                locale.more,
                style: textTheme.bodyLarge!.copyWith(
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateAge(String dob) {
    final DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dob);
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
