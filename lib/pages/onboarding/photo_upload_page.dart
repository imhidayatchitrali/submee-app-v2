import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/utils/enum.dart';

import '../../generated/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/profile_image_upload.dart';

class PhotoUploadPage extends HookConsumerWidget {
  const PhotoUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final onboarding = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    final auth = ref.read(authProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    // Create a state for multiple photos (up to 6)
    final photos = useState<List<File?>>([
      null,
      null,
      null,
      null,
      null,
      null,
    ]);

    // Determine if we should enable the continue button
    // We need at least 1 photo to continue
    final canContinue = photos.value.where((e) => e != null).length == 2;
    return Column(
      spacing: 30,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textTheme.labelMedium,
            children: [
              TextSpan(text: '${locale.upload_profile_picture_1}\n'),
              TextSpan(
                text: '${locale.upload_profile_picture_2} ',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: '${locale.upload_profile_picture_3}!'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            locale.photo_upload_description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Container(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6, // Fixed 6 photo slots
              itemBuilder: (context, index) {
                return ProfileImageUpload(
                  onImageSelected: (image) {
                    final tempList = List<File?>.from(photos.value);
                    tempList[index] = image;
                    photos.value = tempList;
                  },
                );
              },
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: canContinue ? primaryColor : const Color(0xFF98E5BE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () async {
            if (!canContinue) return;
            try {
              await onboardingNotifier.submitUserPhotos(photos.value.whereType<File>().toList());
              auth.moveOnboardingNextStep(OnboardingStep.showCompleted);
            } catch (_) {}
          },
          child: onboarding.isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  locale.continue_label,
                  style: const TextStyle(fontSize: 16),
                ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
