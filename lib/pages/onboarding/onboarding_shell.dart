import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/theme/app_theme.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/widgets/progress_step.dart';

import '../../providers/auth_provider.dart';

class OnboardingShell extends ConsumerWidget {
  const OnboardingShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            ref.read(authProvider).exitOnboarding();
          },
          child: Container(
            decoration: BoxDecoration(gradient: AppTheme.mainGradient),
            padding: AppTheme.screenPadding,
            child: Column(
              spacing: 36,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  spacing: 16,
                  children: [
                    Visibility(
                      visible: _getCurrentStep(context) != 4,
                      replacement: const SizedBox.shrink(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: ref.read(authProvider).exitOnboarding,
                            child: const Icon(Icons.chevron_left),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            locale.create_your_account,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ProgressStep(
                          status: _getCurrentStep(context) == 0
                              ? ProgressStepStatus.active
                              : ProgressStepStatus.completed,
                          assetPath: 'assets/icons/form.svg',
                        ),
                        ProgressLine(
                          isActive: _getCurrentStep(context) > 0,
                        ),
                        ProgressStep(
                          status: _getCurrentStep(context) > 1
                              ? ProgressStepStatus.completed
                              : _getCurrentStep(context) == 1
                                  ? ProgressStepStatus.active
                                  : ProgressStepStatus.inactive,
                          assetPath: 'assets/icons/phone.svg',
                        ),
                        ProgressLine(
                          isActive: _getCurrentStep(context) > 1,
                        ),
                        ProgressStep(
                          status: _getCurrentStep(context) > 2
                              ? ProgressStepStatus.completed
                              : _getCurrentStep(context) == 2
                                  ? ProgressStepStatus.active
                                  : ProgressStepStatus.inactive,
                          assetPath: 'assets/icons/upload-picture.svg',
                        ),
                        ProgressLine(
                          isActive: _getCurrentStep(context) > 2,
                        ),
                        ProgressStep(
                          status: _getCurrentStep(context) > 3
                              ? ProgressStepStatus.completed
                              : _getCurrentStep(context) == 3
                                  ? ProgressStepStatus.active
                                  : ProgressStepStatus.inactive,
                          assetPath: 'assets/icons/filters.svg',
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCurrentStep(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/onboarding/details':
        return 0;
      case '/onboarding/phone':
        return 1;
      case '/onboarding/photo':
        return 2;
      case '/onboarding/completed':
        return 4;
      default:
        return 0;
    }
  }
}

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({super.key});

  int _getCurrentStep(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/onboarding/details':
        return 0;
      case '/onboarding/phone':
        return 1;
      case '/onboarding/photo':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep(context);

    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= currentStep ? const Color(0xFF98E5BE) : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
