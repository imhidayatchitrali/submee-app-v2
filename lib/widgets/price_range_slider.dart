import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/constant.dart';

import '../generated/l10n.dart';

class PriceRangeSliderWidget extends HookWidget {
  const PriceRangeSliderWidget({
    required this.onChanged,
    this.start,
    this.end,
    super.key,
  });
  final Function(double, double) onChanged;
  final double? start;
  final double? end;
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final startValue = useState<double>(start ?? minPriceDefault);
    final endValue = useState<double>(end ?? maxPriceDefault);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                locale.price_by_night,
                style: textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF252525),
                ),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceBox(startValue.value, context),
                  _buildPriceBox(endValue.value, context),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context),
                child: RangeSlider(
                  values: RangeValues(startValue.value, endValue.value),
                  min: minPriceDefault,
                  max: maxPriceDefault,
                  divisions: ((maxPriceDefault - minPriceDefault) / 5).round(),
                  onChanged: (RangeValues values) {
                    startValue.value = (values.start / 5).round() * 5;
                    endValue.value = (values.end / 5).round() * 5;
                  },
                ),
              ),
            ],
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            onPressed: () {
              onChanged(
                startValue.value,
                endValue.value,
              );
              Navigator.of(context).pop();
            },
            child: Text(
              locale.apply_button,
              style: textTheme.bodyLarge!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(double price, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 23),
      decoration: BoxDecoration(
        color: const Color(0xFF99E2C2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor,
        ),
      ),
      child: Center(
        child: Text(
          '\$ ${price.toInt()}',
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF464646),
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}
