import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class InputTextForm extends StatelessWidget {
  const InputTextForm({
    super.key,
    required this.hint,
    this.controller,
    this.value,
    this.iconName,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.disabled = false,
  });
  final TextEditingController? controller;
  final bool isPassword;
  final bool obscureText;
  final bool disabled;
  final String hint;
  final String? iconName;
  final String? value;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      onChanged: onChanged,
      initialValue: value,
      enabled: !disabled,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      onTap: hint == 'Date of birth'
          ? () async {
              final DateTime now = DateTime.now();
              final DateTime minAge = now.subtract(const Duration(days: 365 * 18)); // 18 years ago
              final DateTime maxAge =
                  now.subtract(const Duration(days: 365 * 100)); // 100 years ago

              final initialDate = controller != null && controller?.text != ''
                  ? DateFormat('MM/dd/yyyy').parse(controller!.text)
                  : minAge;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate, // Start with 18 years ago
                firstDate: maxAge, // Allow dates up to 100 years ago
                lastDate: minAge, // Don't allow future dates
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryColor, // your theme color
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                if (onChanged != null) {
                  onChanged!('${picked.month}/${picked.day}/${picked.year}');
                }
              }
            }
          : null,
      decoration: InputDecoration(
        hintText: hint,
        errorStyle: const TextStyle(height: 0, fontSize: 0),
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        prefixIcon: iconName != null
            ? SizedBox(
                height: 15,
                width: 15,
                child: Center(
                  child: CustomSvgPicture(
                    'assets/icons/$iconName.svg',
                  ),
                ),
              )
            : null,
        fillColor: disabled ? Colors.grey[200] : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }
}
