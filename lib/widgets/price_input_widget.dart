import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class PriceInputWidget extends HookWidget {

  const PriceInputWidget({
    super.key,
    this.initialPrice,
    required this.onPriceChanged,
  });
  final double? initialPrice;
  final void Function(double) onPriceChanged;

  @override
  Widget build(BuildContext context) {
    final currentPrice = useState(initialPrice ?? 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF252525)),
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  currentPrice.value -= 5;
                  onPriceChanged(currentPrice.value);
                },
                style: IconButton.styleFrom(
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                      .format(currentPrice.value),
                  style: const TextStyle(
                    fontSize: 26,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  currentPrice.value += 5;
                  onPriceChanged(currentPrice.value);
                },
                style: IconButton.styleFrom(
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Per night',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              children: const [
                TextSpan(
                    text: 'Places like yours in your area usually range from ',),
                TextSpan(
                  text: '\$320 to \$450',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
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
