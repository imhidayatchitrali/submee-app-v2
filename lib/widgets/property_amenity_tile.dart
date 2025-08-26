import 'package:flutter/material.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class AmenityTile extends StatelessWidget {
  const AmenityTile({
    required this.icon,
    required this.text,
    this.color,
  });
  final String icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        spacing: 8,
        children: [
          CustomSvgPicture(
            'assets/icons/$icon.svg',
            color: color ?? primaryColor,
            height: 11,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
