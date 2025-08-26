import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_svg_picture.dart';

class CompletionPage extends HookConsumerWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final auth = ref.read(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      spacing: 30,
      children: [
        Image.asset(
          'assets/images/completion.png',
          width: double.infinity,
          fit: BoxFit.fitHeight,
        ),
        Text(
          locale.signed_up_successfully,
          style: textTheme.displayMedium!.copyWith(fontSize: 24),
        ),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: auth.checkAuthentication,
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                locale.start_looking_for_sublet,
                style: const TextStyle(fontSize: 16),
              ),
              const CustomSvgPicture(
                'assets/icons/search.svg',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
