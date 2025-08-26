import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../utils/functions.dart';
import '../widgets/input_text_form.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useState(GlobalKey<FormState>());
    final textTheme = Theme.of(context).textTheme;
    final locale = S.of(context);
    final email = useState('');
    final password = useState('');
    final obscureText = useState(true);
    final isLoading = useState(false);
    final error = useState<String?>(null);
    final primaryColor = Theme.of(context).primaryColor;
    final size = MediaQuery.sizeOf(context);
    // Validation functions
    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return locale.email_required;
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return locale.email_invalid;
      }
      return null;
    }

    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return locale.password_required;
      }
      if (value.length < 8) {
        return locale.password_length;
      }
      return null;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      '${locale.welcome_back},',
                      style: textTheme.displayMedium,
                    ),
                    Text(
                      locale.login_instruction,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    SizedBox(height: size.height * 0.05),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 25,
                      children: [
                        InputTextForm(
                          hint: locale.email_address,
                          value: email.value,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => email.value = value,
                          validator: validateEmail,
                        ),
                        InputTextForm(
                          hint: locale.password_label,
                          value: password.value,
                          isPassword: true,
                          obscureText: obscureText.value,
                          validator: validatePassword,
                          onChanged: (value) => password.value = value,
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
                        if (error.value != null)
                          Text(
                            error.value!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/forgot-password');
                            },
                            child: Text(
                              locale.page_forgot_password,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.value.currentState!.validate()) {
                  try {
                    isLoading.value = true;
                    error.value = null;
                    await ref.read(authProvider).signInWithEmail(
                          email: email.value,
                          password: password.value,
                        );
                  } catch (e) {
                    error.value = getDatabaseItemNameTranslation(e.toString(), locale);
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
                  : Text(
                      locale.log_in,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
