import 'package:flutter/material.dart';
import 'package:submee/utils/enum.dart';

class AppTheme {
  // Save color
  static const Color subletColor = Color(0xFF21C17A);
  static const Color hostColor = Color(0xFF317DC9);
  static const Color redColor = Color(0xFFFFCCCC);

  static Color primaryColor = subletColor;
  static Color secondaryColor = hostColor;

  static ThemeData getTheme({
    required AppType type,
  }) {
    primaryColor = type == AppType.sublet ? subletColor : hostColor;
    secondaryColor = type == AppType.sublet ? hostColor : subletColor;
    return ThemeData(
      // Colors
      primaryColor: primaryColor,
      primaryColorDark: secondaryColor,
      scaffoldBackgroundColor: Colors.white,

      // Text Theme
      textTheme: const TextTheme(
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          height: 1.4,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontWeight: FontWeight.w300,
          fontSize: 15,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF949494),
          backgroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          side: const BorderSide(color: Color(0xFF828282)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
        ),
      ),
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xFF828282),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          foregroundColor: Colors.black,
          elevation: 0,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor.withValues(alpha: 0.5),
        inactiveTrackColor: const Color(0xFFD9D9D9),
        thumbColor: primaryColor.withValues(alpha: 0.5),
        trackHeight: 10,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
        showValueIndicator: ShowValueIndicator.never,
        rangeThumbShape: CustomRangeThumbShape(
          enabledThumbRadius: 12,
          elevation: 0,
          outerColor: primaryColor.withValues(alpha: 0.5),
          innerColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFFA6A6A6);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return const Color(0xFFE5E5E5);
        }),
      ),
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFCBCBCB),
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
    );
  }

  // Get gradient based on primary color
  static LinearGradient get mainGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.3, 0.7, 1.0],
        colors: [
          primaryColor.withValues(alpha: 0.01),
          primaryColor.withValues(alpha: 0.04),
          primaryColor.withValues(alpha: 0.08),
          primaryColor.withValues(alpha: 0.12),
        ],
      );

  // Common padding
  static const EdgeInsets screenPadding = EdgeInsets.only(
    right: 20,
    left: 20,
    top: 20,
    bottom: 20,
  );
}

class CustomRangeThumbShape extends RangeSliderThumbShape {
  const CustomRangeThumbShape({
    this.enabledThumbRadius = 12.0,
    this.elevation = 0.0,
    this.outerColor = Colors.green,
    this.innerColor = Colors.white,
  });
  final double enabledThumbRadius;
  final double elevation;
  final Color outerColor;
  final Color innerColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    // Paint the outer circle
    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, outerPaint);

    // Paint the inner white circle
    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius * 0.6, innerPaint);
  }
}
