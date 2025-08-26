import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/utils/enum.dart';

import '../theme/app_theme.dart';
import 'otp_input_field.dart';

class ValidateOtpModal extends HookWidget {
  const ValidateOtpModal({
    super.key,
    required this.source,
    required this.onSubmit,
  });
  final String source;
  final Future Function(String) onSubmit;
  @override
  Widget build(BuildContext context) {
    final transactionStatus = useState<TransactionStatus>(TransactionStatus.idle);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      spacing: 20,
      children: [
        Column(
          spacing: 8,
          children: [
            Text(
              'Verify OTP',
              style: textTheme.displayMedium,
            ),
            Text(
              'We\'ve sent OTP code to $source, confirm code.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
        if (transactionStatus.value == TransactionStatus.idle)
          OtpInputField(
            onChange: (code) async {
              if (code.length < 4) {
                return;
              }
              try {
                transactionStatus.value = TransactionStatus.loading;
                await onSubmit(code);
                transactionStatus.value = TransactionStatus.success;
                await Future.delayed(const Duration(seconds: 2));
                Navigator.of(context).pop();
              } catch (e) {
                transactionStatus.value = TransactionStatus.error;
                await Future.delayed(const Duration(seconds: 2));
                transactionStatus.value = TransactionStatus.idle;
              }
            },
          ),
        if (transactionStatus.value == TransactionStatus.loading)
          const Center(
            child: CircularProgressIndicator(
              color: AppTheme.subletColor,
            ),
          ),
        if (transactionStatus.value == TransactionStatus.success)
          const Icon(
            Icons.check_circle,
            color: AppTheme.subletColor,
            size: 40,
          ),
        if (transactionStatus.value == TransactionStatus.error)
          const Icon(
            Icons.error,
            color: AppTheme.redColor,
            size: 40,
          ),
      ],
    );
  }
}
