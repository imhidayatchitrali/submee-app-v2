import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/utils/custom_toast.dart';

import '../../generated/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/enum.dart';
import '../../utils/functions.dart';
import '../../widgets/country_region_input.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/phone_number_input.dart';

// Since we dont have Twilio we are not sending the code
const ALLOW_CODE = false;

class PhoneVerificationPage extends HookConsumerWidget {
  const PhoneVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final locale = S.of(context);
    final onboarding = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;
    final otpCode = useState('');
    final codeSend = useState(false);
    return Column(
      spacing: 11,
      children: [
        CountryRegionInput(
          onCountryChanged: (code, dialCode) {
            onboardingNotifier.setCountry(code, dialCode);
          },
        ),
        PhoneNumberInput(
          allowSendCode: onboarding.dialCode.isNotEmpty,
          onChanged: onboardingNotifier.setPhoneNumber,
          // onSendCode: (phoneNumber) {
          //   onboardingNotifier.sendCode(phoneNumber);
          // },
        ),
        Visibility(
          visible: onboarding.showOTP,
          replacement: const SizedBox.shrink(),
          child: OtpInputField(
            onChange: (otp) {
              otpCode.value = otp;
            },
          ),
        ),
        // Phone verification UI
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: (codeSend.value && otpCode.value.length == 4 ||
                    !codeSend.value &&
                        onboarding.phoneNumber.isNotEmpty &&
                        onboarding.phoneNumber.length > 5)
                ? primaryColor
                : const Color(0xFF98E5BE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () async {
            try {
              // TODO(krupikivan): Remove this when Twilio is implemented
              if (!ALLOW_CODE) {
                await onboardingNotifier.mockCodeVerification(onboarding.phoneNumber);
                auth.moveOnboardingNextStep(OnboardingStep.photoUpload);
                return;
              }
              if (!codeSend.value &&
                  onboarding.phoneNumber.isNotEmpty &&
                  onboarding.phoneNumber.length > 5) {
                codeSend.value = true;
                await onboardingNotifier.sendCode(onboarding.phoneNumber);
                ref.read(customToastProvider).show(
                      locale.verification_code_sent,
                      duration: const Duration(seconds: 3),
                    );
              } else {
                if (otpCode.value.length == 4) {
                  await onboardingNotifier.verifyCode(otpCode.value);
                  auth.moveOnboardingNextStep(OnboardingStep.photoUpload);
                }
              }
            } catch (e) {
              ref.read(customToastProvider).show(
                    getDatabaseItemNameTranslation(e.toString(), locale),
                    duration: const Duration(seconds: 3),
                  );
            }
          },
          child: onboarding.isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Visibility(
                  visible: !ALLOW_CODE || codeSend.value,
                  replacement: Text(
                    locale.send_code,
                    style: const TextStyle(fontSize: 16),
                  ),
                  child: Text(
                    locale.continue_label,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
        ),
      ],
    );
  }
}
