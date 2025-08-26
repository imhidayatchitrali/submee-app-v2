import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'custom_calendar_widget.dart';
import 'last_minute_offer_widget.dart';
import 'price_input_widget.dart';

class PublishPlaceOnboardingDate extends HookWidget {
  const PublishPlaceOnboardingDate({
    super.key,
    required this.onPriceChanged,
    required this.onLastMinuteOffer,
    required this.onDateRangeChanged,
    this.price,
    this.lastMinuteOffer,
    this.startDate,
    this.endDate,
  });
  final Function(double) onPriceChanged;
  final Function(bool) onLastMinuteOffer;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final double? price;
  final bool? lastMinuteOffer;
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox.shrink(),
          CustomCalendarWidget(
            startDateSelected: startDate,
            endDateSelected: endDate,
            onDateRangeChanged: onDateRangeChanged,
          ),
          LastMinuteOffers(
            value: lastMinuteOffer,
            onChanged: onLastMinuteOffer,
          ),
          PriceInputWidget(
            initialPrice: price,
            onPriceChanged: onPriceChanged,
          ),
        ],
      ),
    );
  }
}
