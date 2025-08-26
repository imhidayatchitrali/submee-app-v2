import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/services/user_service.dart';
import 'package:submee/utils/banners.dart';
import 'package:submee/utils/enum.dart';

import '../../generated/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gender_selection.dart';
import '../../widgets/input_text_form.dart';
import '../../widgets/profile_image_upload.dart';
import '../../widgets/progress_step.dart';

class CompleteProfilePage extends HookConsumerWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final buttonStyle = Theme.of(context).filledButtonTheme.style;
    final step = useState(0);
    final auth = ref.watch(authProvider);
    final loading = useState(false);
    final firstName = useState(auth.user?.firstName);
    final lastName = useState(auth.user?.lastName);
    final instagram = useState(auth.user?.instagramUsername);
    final facebook = useState(auth.user?.facebookUsername);
    final gender = useState(auth.user?.gender);
    final photos = useState<List<File?>>([
      null,
      null,
      null,
      null,
      null,
      null,
    ]);

    bool validateFieldEachStep() {
      if (step.value == 0) {
        return true;
      } else if (step.value == 1) {
        return firstName.value != null &&
            firstName.value!.isNotEmpty &&
            lastName.value != null &&
            lastName.value!.isNotEmpty;
      } else if (step.value == 2) {
        return true;
      } else {
        return true;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              children: [
                const ProgressStep(
                  status: ProgressStepStatus.completed,
                ),
                ProgressLine(
                  isActive: step.value > 0,
                ),
                ProgressStep(
                  status:
                      step.value > 0 ? ProgressStepStatus.completed : ProgressStepStatus.inactive,
                ),
                ProgressLine(
                  isActive: step.value > 1,
                ),
                ProgressStep(
                  status:
                      step.value > 1 ? ProgressStepStatus.completed : ProgressStepStatus.inactive,
                ),
              ],
            ),
          ),
          if (step.value == 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  spacing: 20,
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
                            final photoExistOnPosition =
                                auth.user?.photos?.where((e) => e.order == index + 1).firstOrNull;

                            return ProfileImageUpload(
                              imageUrl: photoExistOnPosition?.url,
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
                  ],
                ),
              ),
            ),
          if (step.value == 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 30,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 25,
                        children: [
                          Text(
                            locale.firts_last_name,
                            style: textTheme.labelMedium,
                          ),
                          InputTextForm(
                            hint: locale.first_name_hint,
                            value: firstName.value,
                            onChanged: (value) => firstName.value = value,
                          ),
                          InputTextForm(
                            hint: locale.last_name_hint,
                            value: lastName.value,
                            onChanged: (value) => lastName.value = value,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 25,
                        children: [
                          Text(
                            locale.social_media_links,
                            style: textTheme.labelMedium,
                          ),
                          InputTextForm(
                            hint: '@',
                            iconName: 'instagram',
                            value: instagram.value,
                            onChanged: (value) => instagram.value = value,
                          ),
                          InputTextForm(
                            hint: '@',
                            iconName: 'facebook',
                            value: facebook.value,
                            onChanged: (value) => facebook.value = value,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (step.value == 2)
            GenderSelection(
              selected: gender.value,
              onGenderChanged: (value) => gender.value = value,
            ),
          FilledButton(
            style: buttonStyle?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                validateFieldEachStep() ? primaryColor : primaryColor.withValues(alpha: 0.5),
              ),
            ),
            onPressed: () async {
              try {
                if (!validateFieldEachStep()) {
                  return;
                }
                if (step.value < 2) {
                  step.value++;
                  return;
                }
                loading.value = true;
                await ref.read(userService).updateUserPhotos(
                      photos.value,
                    );
                await ref.read(userService).updateUser(
                      firstName: firstName.value,
                      lastName: lastName.value,
                      gender: gender.value,
                      instagram: instagram.value,
                      facebook: facebook.value,
                    );
                ref.read(authProvider).retrieveUser();
                if (context.mounted) {
                  showSuccessBanner(
                    context,
                    title: locale.profile_updated,
                    body: locale.profile_updated_body,
                    buttonText: locale.continue_label,
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    if (context.mounted) {
                      context.go('/account');
                    }
                  });
                }
              } finally {
                loading.value = false;
              }
            },
            child: loading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    step.value == 2 ? locale.update : locale.continue_label,
                  ),
          ),
        ],
      ),
    );
  }
}
