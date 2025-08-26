import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../generated/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/environment_service.dart';
import '../utils/banners.dart';
import '../utils/validators.dart';
import '../widgets/input_text_form.dart';

class SetNewPasswordPage extends HookConsumerWidget {
  const SetNewPasswordPage(this.token, {super.key});
  final String token;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final obscureText = useState(true);
    final password = useState<String?>(null);
    final env = ref.watch(environmentService).environment.environmentName;
    final primaryColor = Theme.of(context).primaryColor;
    final isLoading = useState(false);
    final locale = S.of(context);
    return SingleChildScrollView(
      child: Column(
        spacing: 75,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 8,
            children: [
              Text(
                locale.set_new_password_heading,
                style: textTheme.displayMedium,
              ),
              Text(
                locale.set_new_password_description,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          Column(
            spacing: 25,
            children: [
              InputTextForm(
                hint: locale.password_label,
                isPassword: true,
                obscureText: obscureText.value,
                validator: (value) => validatePassword(value, env),
                onChanged: (value) {
                  password.value = value;
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
                hint: locale.confirm_password_hint,
                isPassword: true,
                obscureText: obscureText.value,
                validator: (value) => validateConfirmPassword(value, password.value),
              ),
            ],
          ),
          FilledButton(
            onPressed: () async {
              if (password.value != null) {
                try {
                  isLoading.value = true;
                  await ref.read(authProvider).resetPassword(
                        password: password.value!,
                        token: token,
                      );
                  if (context.mounted) {
                    showSuccessBanner(
                      context,
                      title: locale.password_change_success_title,
                      body: locale.password_change_success_body,
                      buttonText: locale.password_change_success_button,
                      onPressed: () {
                        context.go('/login');
                      },
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showFailedBanner(
                      context,
                      title: locale.password_change_failed_title,
                      body: locale.password_change_failed_body,
                      buttonText: locale.password_change_failed_button,
                    );
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
                : Text(
                    locale.done_button,
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
    );
  }
}
