import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/functions.dart';
import 'package:submee/widgets/custom_back_button.dart';

import '../../generated/l10n.dart';

class OnlyAppbarLayout extends ConsumerWidget {
  const OnlyAppbarLayout({
    super.key,
    required this.child,
    required this.title,
  });
  final Widget child;
  final String? title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: Column(
        children: [
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            color: primaryColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 8,
            ),
            child: Row(
              children: [
                const CustomBackButton(),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      getDatabaseItemNameTranslation(title, S.of(context)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
