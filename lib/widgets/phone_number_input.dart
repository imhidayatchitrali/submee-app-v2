import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../generated/l10n.dart';

class PhoneNumberInput extends HookWidget {
  const PhoneNumberInput({
    // required this.onSendCode,
    required this.allowSendCode,
    required this.onChanged,
    super.key,
  });
  // final void Function(String) onSendCode;
  final void Function(String) onChanged;
  final bool allowSendCode;
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final phoneController = useTextEditingController();
    final primaryColor = Theme.of(context).primaryColor;
    final hasPhoneNumber = useState(false);
    // final isCountdownActive = useState(false);
    // final countdown = useState(60);
    // final timer = useRef<Timer?>(null);

    // Effect for phone number changes
    useEffect(
      () {
        void onPhoneNumberChanged() {
          hasPhoneNumber.value = phoneController.text.isNotEmpty;
        }

        phoneController.addListener(onPhoneNumberChanged);
        return () => phoneController.removeListener(onPhoneNumberChanged);
      },
      [phoneController],
    );

    // Cleanup timer on dispose
    // useEffect(
    //   () {
    //     return () => timer.value?.cancel();
    //   },
    //   [],
    // );

    // void startCountdown() {
    //   isCountdownActive.value = true;
    //   countdown.value = 60;

    //   timer.value?.cancel();
    //   timer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
    //     if (countdown.value > 0) {
    //       countdown.value--;
    //     } else {
    //       isCountdownActive.value = false;
    //       timer.cancel();
    //     }
    //   });
    // }

    // void handleSendCode() {
    //   if (hasPhoneNumber.value && !isCountdownActive.value) {
    //     onSendCode(phoneController.text);
    //     startCountdown();
    //   }
    // }

    // Color getButtonColor() {
    //   if (isCountdownActive.value) {
    //     return primaryColor;
    //   }
    //   return hasPhoneNumber.value && allowSendCode
    //       ? primaryColor
    //       : const Color(0xFFB0B0B0).withValues(alpha: 0.3);
    // }

    // String getButtonText() {
    //   if (isCountdownActive.value) {
    //     return '${countdown.value} sec';
    //   }
    //   return 'Send code';
    // }

    // final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasPhoneNumber.value ? primaryColor : const Color(0xFFB0B0B0),
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: phoneController,
              onChanged: onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: locale.phone_number,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: handleSendCode,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 16.0,
          //       vertical: 8.0,
          //     ),
          //     decoration: BoxDecoration(
          //       color: getButtonColor(),
          //       borderRadius: BorderRadius.circular(20.0),
          //     ),
          //     child: Text(
          //       getButtonText(),
          //       style: textTheme.labelSmall!.copyWith(
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
