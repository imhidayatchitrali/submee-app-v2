import 'package:flutter/material.dart';
import 'package:submee/utils/enum.dart';

import 'custom_svg_picture.dart';

class ProgressStep extends StatelessWidget {
  const ProgressStep({
    super.key,
    required this.status,
    this.assetPath,
  });
  final ProgressStepStatus status;
  final String? assetPath;

  Color _getColor(Color primaryColor) {
    switch (status) {
      case ProgressStepStatus.active:
        return primaryColor.withValues(alpha: .2);
      case ProgressStepStatus.inactive:
        return primaryColor.withValues(alpha: .2);
      case ProgressStepStatus.completed:
        return primaryColor;
    }
  }

  Color _getIconColor(Color primaryColor) {
    switch (status) {
      case ProgressStepStatus.active:
        return primaryColor;
      case ProgressStepStatus.inactive:
        return Colors.white;
      case ProgressStepStatus.completed:
        return Colors.white;
    }
  }

  String? _getPath() {
    switch (status) {
      case ProgressStepStatus.completed:
        return 'assets/icons/check.svg';
      default:
        return assetPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(primaryColor),
      ),
      child: Visibility(
        visible: _getPath() != null,
        replacement: const SizedBox(
          height: 20,
          width: 20,
        ),
        child: CustomSvgPicture(
          _getPath() ?? '',
          height: 10,
          color: _getIconColor(primaryColor),
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.isActive,
  });
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: Container(
        height: 1,
        color: isActive ? primaryColor : const Color(0xFFE0E0E0),
      ),
    );
  }
}
