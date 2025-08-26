import 'package:flutter/material.dart';
import 'package:submee/generated/l10n.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class InputSearch extends StatelessWidget {
  const InputSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.value,
  });
  final TextEditingController? controller;
  final String? value;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        initialValue: value,
        style: theme.textTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: locale.search,
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          hintStyle: const TextStyle(color: Colors.white),
          filled: true,
          prefixIcon: const SizedBox(
            height: 15,
            width: 15,
            child: Center(
              child: CustomSvgPicture(
                'assets/icons/search.svg',
              ),
            ),
          ),
          fillColor: primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: Colors.white),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
