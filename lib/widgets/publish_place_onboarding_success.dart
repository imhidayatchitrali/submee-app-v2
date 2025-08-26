import 'package:flutter/material.dart';
import 'package:submee/models/property.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../generated/l10n.dart';

class PublishPlaceOnboardingSuccess extends StatelessWidget {
  const PublishPlaceOnboardingSuccess({
    super.key,
    required this.property,
  });
  final PropertyInput property;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      child: Column(
        spacing: 34,
        children: [
          Image.asset(
            'assets/images/completion_host.png',
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
          Text(
            '${locale.successfully_listed}!',
            style: textTheme.displayMedium!.copyWith(fontSize: 24),
          ),
          // Row(
          //   spacing: 19,
          //   children: [
          //     Expanded(
          //       flex: 6,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(10),
          //           border: Border.all(
          //             color: const Color(0xFF323232).withValues(alpha: 0.1),
          //             width: 1,
          //           ),
          //         ),
          //         padding: const EdgeInsets.only(left: 5, top: 20, bottom: 20),
          //         child: Row(
          //           spacing: 8,
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           children: [
          //             const CustomSvgPicture('assets/icons/share.svg'),
          //             Flexible(
          //               child: Text(
          //                 'Share property',
          //                 style: textTheme.labelLarge,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     Flexible(
          //       flex: 5,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(10),
          //           border: Border.all(
          //             color: const Color(0xFF323232).withValues(alpha: 0.1),
          //             width: 1,
          //           ),
          //         ),
          //         padding: const EdgeInsets.only(left: 5, top: 20, bottom: 20),
          //         child: Row(
          //           spacing: 8,
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           children: [
          //             const CustomSvgPicture('assets/icons/preview.svg'),
          //             Flexible(
          //               child: Text(
          //                 'Preview',
          //                 style: textTheme.labelLarge,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF323232).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              spacing: 28,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        CustomSvgPicture(
                          'assets/icons/calendar.svg',
                          height: 15,
                          color: primaryColor,
                        ),
                        Text(
                          locale.dates,
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                    Text(
                      formatDatePreview(property.startDate, property.endDate),
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        CustomSvgPicture(
                          'assets/icons/price.svg',
                          height: 15,
                          color: primaryColor,
                        ),
                        Text(
                          locale.total_price,
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                    Text(
                      '\$${property.price.ceil()}',
                      style: textTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.bold,
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
