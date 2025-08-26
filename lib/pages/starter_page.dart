import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/providers/auth_provider.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../generated/l10n.dart';
import '../theme/app_theme.dart';

class StarterPage extends ConsumerWidget {
  const StarterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mainGradient),
        height: size.height, // Ensure container takes full height
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: AppTheme.screenPadding,
                      child: Column(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Image.asset(
                              'assets/images/presentation.png',
                              height: size.width * 0.8, // Adjust height proportionally
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Title text
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '${locale.starter_page_first_title}\n',
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              children: [
                                TextSpan(
                                  text: locale.starter_page_second_title,
                                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Login buttons
                          Column(
                            spacing: 20,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  context.push('/login');
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      locale.login_with_email,
                                      style: textTheme.labelLarge!.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton(
                                onPressed: () {
                                  if (Platform.isIOS) {
                                    ref.read(authProvider).signInWithApple();
                                  } else {
                                    ref.read(authProvider).signInWithGoogle();
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Row(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomSvgPicture(
                                      'assets/icons/${Platform.isIOS ? 'apple' : 'google'}.svg',
                                    ),
                                    Text(
                                      Platform.isIOS
                                          ? locale.login_with_apple
                                          : locale.login_with_google,
                                      style: textTheme.labelLarge!,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Register text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                locale.dont_have_account,
                                style: textTheme.bodyLarge!.copyWith(
                                  color: primaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: ref.read(authProvider).startOnboarding,
                                child: Text(
                                  locale.register,
                                  style: textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
