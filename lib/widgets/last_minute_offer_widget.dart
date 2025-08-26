import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class LastMinuteOffers extends HookWidget {
  const LastMinuteOffers({
    super.key,
    required this.onChanged,
    this.value,
  });
  final Function(bool) onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    final isEnabled = useState(value ?? false);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Last minute offers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const CustomSvgPicture(
                    'assets/icons/power.svg',
                    color: Colors.black,
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Open to last-minute sublet offers?',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          Switch(
            trackColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? primaryColor : const Color(0xFFE5E5E5),
            ),
            value: isEnabled.value,
            onChanged: (value) {
              isEnabled.value = value;
              onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
