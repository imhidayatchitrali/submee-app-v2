import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.size = 120,
    this.onTap,
  });
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.5),
            style: BorderStyle.none,
          ),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: Colors.grey.withValues(alpha: 0.5),
            strokeWidth: 1.0,
            gap: 5.0,
            radius: 20.0,
          ),
          child: const Center(
            child: CustomSvgPicture(
              'assets/icons/photo-placeholder.svg',
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    const double dash = 5;

    // Helper function to create dashed arc
    void drawDashedArc(Offset center, double startAngle, double sweepAngle) {
      final double arcLength = radius * sweepAngle;
      final int dashCount = (arcLength / (dash + gap)).ceil();
      final double eachAngle = sweepAngle / dashCount;

      for (int i = 0; i < dashCount; i++) {
        final double startArcAngle = startAngle + (i * eachAngle);
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          startArcAngle,
          eachAngle * 0.7, // Multiply by factor less than 1 to create gap
        );
      }
    }

    // Top right corner
    drawDashedArc(
      Offset(size.width - radius, radius),
      -math.pi / 2,
      math.pi / 2,
    );

    // Right side
    for (double i = radius; i < size.height - radius; i += dash + gap) {
      path.moveTo(size.width, i);
      path.lineTo(size.width, math.min(i + dash, size.height - radius));
    }

    // Bottom right corner
    drawDashedArc(
      Offset(size.width - radius, size.height - radius),
      0,
      math.pi / 2,
    );

    // Bottom side
    for (double i = size.width - radius; i > radius; i -= dash + gap) {
      path.moveTo(i, size.height);
      path.lineTo(math.max(i - dash, radius), size.height);
    }

    // Bottom left corner
    drawDashedArc(
      Offset(radius, size.height - radius),
      math.pi / 2,
      math.pi / 2,
    );

    // Left side
    for (double i = size.height - radius; i > radius; i -= dash + gap) {
      path.moveTo(0, i);
      path.lineTo(0, math.max(i - dash, radius));
    }

    // Top left corner
    drawDashedArc(
      Offset(radius, radius),
      math.pi,
      math.pi / 2,
    );

    // Top side
    for (double i = radius; i < size.width - radius; i += dash + gap) {
      path.moveTo(i, 0);
      path.lineTo(math.min(i + dash, size.width - radius), 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
