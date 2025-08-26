import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/theme/app_theme.dart';

class UnauthLayout extends ConsumerWidget {
  const UnauthLayout({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        padding: AppTheme.screenPadding,
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 8,
                ),
                child: const Icon(Icons.chevron_left),
              ),
            ),
            // Main Content
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
