import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgPicture extends StatelessWidget {
  const CustomSvgPicture(this.path, {super.key, this.color, this.height});
  final String path;
  final Color? color;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: height ?? 24,
      width: height ?? 24,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
