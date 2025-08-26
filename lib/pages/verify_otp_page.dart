import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/otp_input_field.dart';

class VerifyOTPPage extends HookConsumerWidget {
  const VerifyOTPPage(this.email, {super.key});
  final String email;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = useState(false);
    final code = useState<String?>(null);
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(
        disposition: UnfocusDisposition.scope,
      ),
      child: Column(
        spacing: 75,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 8,
            children: [
              Text(
                'Verify OTP',
                style: textTheme.displayMedium,
              ),
              Text(
                'We\'ve sent OTP code to $email, confirm code.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          OtpInputField(
            onChange: (otp) {
              code.value = otp;
            },
          ),
          FilledButton(
            onPressed: () async {
              if (code.value != null) {
                try {
                  isLoading.value = true;
                  final token = await ref.read(authProvider).verifyCodeOnResetPassword(
                        email: email,
                        code: code.value!,
                      );
                  if (token != null && context.mounted) {
                    context.push('/reset-password', extra: {'token': token});
                  }
                } finally {
                  isLoading.value = false;
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
