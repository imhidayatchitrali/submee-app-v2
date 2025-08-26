import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/input_text_form.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useState(GlobalKey<FormState>());
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final email = useState('');
    final isLoading = useState(false);
    // Validation functions
    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Enter a valid email';
      }
      return null;
    }

    return Form(
      key: formKey.value,
      child: Column(
        spacing: 75,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 8,
            children: [
              Text(
                'Forgot Password',
                style: textTheme.displayMedium,
              ),
              Text(
                'Enter your email to get OTP verify it and set new password',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          Column(
            spacing: 25,
            children: [
              InputTextForm(
                hint: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email.value = value,
                validator: validateEmail,
              ),
            ],
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.value.currentState!.validate()) {
                try {
                  isLoading.value = true;
                  await ref.read(authProvider).forgotPassword(
                        email.value,
                      );
                  if (context.mounted) {
                    context.push('/verify-otp', extra: {'email': email.value});
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
                    'Send OTP',
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
