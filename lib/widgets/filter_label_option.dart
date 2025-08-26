import 'package:flutter/material.dart';

import 'custom_svg_picture.dart';

class FilterLabelOption extends StatelessWidget {
  const FilterLabelOption({
    super.key,
    required this.name,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });
  final String name;
  final String icon;
  final Function onTap;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFABE3C2) : Colors.white,
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            CustomSvgPicture('assets/icons/$icon.svg', height: 22),
            Text(
              name,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
