import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OtpInputField extends HookWidget {
  const OtpInputField({
    super.key,
    required this.onChange,
  });
  final Function(String) onChange;

  @override
  Widget build(BuildContext context) {
    final controllersRef = useRef<List<TextEditingController>?>(null);
    final focusNodesRef = useRef<List<FocusNode>?>(null);
    final primaryColor = Theme.of(context).primaryColor;
    useEffect(
      () {
        controllersRef.value = List.generate(
          4,
          (index) => TextEditingController(),
        );

        focusNodesRef.value = List.generate(
          4,
          (index) => FocusNode(),
        );
        focusNodesRef.value?.first.requestFocus();
        return () {
          controllersRef.value?.forEach((controller) => controller.dispose());
          focusNodesRef.value?.forEach((node) => node.dispose());
        };
      },
      [],
    );

    void onChanged(String value, int index) {
      if (value.isNotEmpty) {
        if (index < 3) {
          focusNodesRef.value?[index + 1].requestFocus();
        }
      }
      final otp = controllersRef.value?.map((c) => c.text).join() ?? '';
      onChange(otp);
    }

    void handleBackspace(int index) {
      if (controllersRef.value?[index].text.isEmpty ?? false) {
        if (index > 0) {
          focusNodesRef.value?[index - 1].requestFocus();
          controllersRef.value?[index - 1].clear();
        }
      } else {
        controllersRef.value?[index].clear();
      }
      onChange(controllersRef.value?.map((c) => c.text).join() ?? '');
    }

    if (controllersRef.value == null || focusNodesRef.value == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                handleBackspace(index);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: controllersRef.value![index],
              focusNode: focusNodesRef.value![index],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              showCursor: false,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 24,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) => onChanged(value, index),
            ),
          ),
        ),
      ),
    );
  }
}
