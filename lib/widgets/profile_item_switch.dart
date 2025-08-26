import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class ProfileItemSwitch extends HookWidget {
  const ProfileItemSwitch({
    required this.title,
    required this.asset,
    this.textColor = Colors.black,
    required this.onChange,
    this.onTap,
    super.key,
  });
  final String title;
  final String? asset;
  final Color? textColor;
  final Function(bool) onChange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = useState(false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                CustomSvgPicture('assets/icons/$asset.svg'),
                Text(
                  title,
                  style: textTheme.bodyLarge!.copyWith(color: textColor),
                ),
              ],
            ),
            Switch.adaptive(
              value: value.value,
              inactiveThumbColor: Colors.white,
              thumbColor: WidgetStateProperty.all(Colors.white),
              inactiveTrackColor: const Color(0xFFEBEBEB),
              activeTrackColor: const Color(0xFF76EE59),
              onChanged: (val) {
                value.value = val;
                onChange(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
