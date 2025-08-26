import 'package:flutter/material.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class FilterOptionButton extends StatelessWidget {
  const FilterOptionButton({
    Key? key,
    required this.onPressed,
    required this.onRemovePressed,
    required this.asset,
    required this.text,
    this.activeLabel,
  }) : super(key: key);
  final VoidCallback onPressed;
  final VoidCallback onRemovePressed;
  final String asset;
  final String text;
  final String? activeLabel;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: activeLabel != null ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: Row(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (activeLabel == null)
                  CustomSvgPicture(
                    'assets/icons/$asset.svg',
                    color: activeLabel != null ? Colors.black : Colors.white,
                  ),
                Text(
                  activeLabel ?? text,
                  style: textTheme.bodyLarge!.copyWith(
                    color: activeLabel != null ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (activeLabel != null)
          Positioned(
            top: -10,
            right: -10,
            child: InkWell(
              onTap: onRemovePressed,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
