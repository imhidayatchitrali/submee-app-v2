import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'custom_svg_picture.dart';

class SearchInput extends HookWidget {
  const SearchInput({
    super.key,
    required this.hint,
    this.value,
    this.validator,
    this.onTap,
    this.onChanged,
  });
  final String hint;
  final String? value;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value ?? '');
    useEffect(
      () {
        controller.text = value ?? '';
        return null;
      },
      [value],
    );
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: false,
        style: theme.textTheme.bodyLarge,
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          prefixIcon: const SizedBox(
            height: 15,
            width: 15,
            child: Center(
              child: CustomSvgPicture(
                'assets/icons/search.svg',
                color: Colors.grey,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }
}
