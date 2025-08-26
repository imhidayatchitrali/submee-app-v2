import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/providers/auth_provider.dart';
import 'package:submee/providers/environment_service.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/utils/validators.dart';
import 'package:submee/widgets/banners/modal_wrapper.dart';
import 'package:submee/widgets/input_text_form.dart';

import '../../generated/l10n.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/custom_toast.dart';
import '../../utils/functions.dart';
import '../../widgets/validate_otp_modal.dart';

class PersonalDetailsPage extends HookConsumerWidget {
  PersonalDetailsPage({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = S.of(context);
    final obscureText = useState(true);
    final onboarding = ref.watch(onboardingProvider);
    final env = ref.watch(environmentService).environment.environmentName;
    final auth = ref.read(authProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    final dobController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final primaryColor = Theme.of(context).primaryColor;

    /// Local state to check if all fields are filled
    final isFormFilled = useState(false);

    /// Function to check required fields
    void checkFormFilled() {
      final filled = onboarding.firstName.isNotEmpty &&
          onboarding.lastName.isNotEmpty &&
          onboarding.email.isNotEmpty &&
          onboarding.dob.isNotEmpty &&
          onboarding.password.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
      isFormFilled.value = filled;
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 11,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputTextForm(
              hint: locale.first_name_hint,
              onChanged: (v) {
                onboardingNotifier.setFirstName(v);
                checkFormFilled();
              },
              validator: validateName,
            ),
            InputTextForm(
              hint: locale.last_name_hint,
              onChanged: (v) {
                onboardingNotifier.setLastName(v);
                checkFormFilled();
              },
              validator: validateName,
            ),
            InputTextForm(
              hint: locale.email_address,
              disabled: onboarding.emailVerified,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) {
                onboardingNotifier.setEmail(v);
                checkFormFilled();
              },
              validator: validateEmail,
              suffixIcon: onboarding.emailVerified
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF98E5BE),
                    )
                  : null,
            ),
            InputTextForm(
              hint: locale.date_of_birth,
              controller: dobController,
              onChanged: (value) {
                onboardingNotifier.setDob(value);
                dobController.text = value;
                checkFormFilled();
              },
            ),
            const SizedBox(height: 22),
            InputTextForm(
              hint: locale.password_label,
              isPassword: true,
              obscureText: obscureText.value,
              validator: (value) => validatePassword(value, env),
              onChanged: (v) {
                onboardingNotifier.setPassword(v);
                checkFormFilled();
              },
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  obscureText.value = !obscureText.value;
                },
              ),
            ),
            InputTextForm(
              hint: locale.confirm_password,
              isPassword: true,
              obscureText: obscureText.value,
              controller: confirmPasswordController,
              validator: (value) => validateConfirmPassword(value, onboarding.password),
              onChanged: (_) => checkFormFilled(),
            ),
            Text(
              locale.password_requirements,
              style: theme.textTheme.labelSmall!.copyWith(
                color: const Color(0xFFB0B0B0),
              ),
            ),
            const SizedBox(height: 25),
            RichText(
              text: TextSpan(
                style: theme.textTheme.labelSmall!
                    .copyWith(color: const Color(0xFF707070), fontSize: 11),
                children: [
                  TextSpan(text: locale.terms_prefix),
                  TextSpan(
                    text: locale.terms_of_service,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: const Color(0xFF369BFF),
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' ${locale.and_acknowledge} '),
                  TextSpan(
                    text: locale.privacy_policy,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: const Color(0xFF369BFF),
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isFormFilled.value
                    ? () async {
                        if (!onboarding.emailVerified) {
                          await onboardingNotifier.sendEmailCode();
                          showCustomModal(
                            context: context,
                            child: ValidateOtpModal(
                              source: onboarding.email,
                              onSubmit: (value) async {
                                try {
                                  await onboardingNotifier.verifyEmailCode(value);
                                } catch (_) {
                                  rethrow;
                                }
                              },
                            ),
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          try {
                            await onboardingNotifier.submitPersonalDetails();
                            if (onboarding.error == null && context.mounted) {
                              auth.moveOnboardingNextStep(
                                OnboardingStep.phoneVerification,
                              );
                            }
                          } catch (e) {
                            ref.read(customToastProvider).show(
                                  getDatabaseItemNameTranslation(e.toString(), locale),
                                  duration: const Duration(seconds: 3),
                                );
                          }
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: isFormFilled.value ? primaryColor : const Color(0xFF98E5BE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: onboarding.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        onboarding.emailVerified ? locale.agree_and_continue : locale.send_code,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
