import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SwitchOption extends HookWidget {
  const SwitchOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onChange,
  }) : super(key: key);
  final String label;
  final bool isSelected;
  final Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    final value = useState(isSelected);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 16,
          children: [
            Text(
              label,
              style: textTheme.bodyLarge!.copyWith(color: Colors.black),
            ),
          ],
        ),
        Switch.adaptive(
          value: value.value,
          inactiveThumbColor: Colors.white,
          thumbColor: WidgetStateProperty.all(Colors.white),
          inactiveTrackColor: const Color(0xFFEBEBEB),
          activeTrackColor: primaryColor,
          onChanged: (val) {
            value.value = val;
            onChange(val);
          },
        ),
      ],
    );
  }
}
