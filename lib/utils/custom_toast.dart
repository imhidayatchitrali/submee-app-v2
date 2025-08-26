import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/router.dart';
import '../providers/router_providers.dart';

final customToastProvider = Provider<CustomToast>((ref) {
  final router = ref.watch(routerProvider);
  return CustomToast(
    router: router,
  );
});

class CustomToast {
  CustomToast({required this.router});

  final AppRouter router;

  void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
    double bottom = 50.0,
  }) {
    // Get the context from the navigator key
    final BuildContext? context = router.router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    final overlay = router.router.routerDelegate.navigatorKey.currentState!.overlay;
    if (overlay == null) {
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) {
        // Calculate the visible bottom area accounting for keyboard
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final actualBottom = keyboardHeight > 0
            ? keyboardHeight + 8.0 // Add a small padding when keyboard is visible
            : bottom;

        return Positioned(
          bottom: actualBottom,
          left: 20.0,
          right: 20.0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
