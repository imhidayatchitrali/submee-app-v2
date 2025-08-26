import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/utils/extension.dart';

class GenderSelection extends HookWidget {
  GenderSelection({
    super.key,
    required this.onGenderChanged,
    required this.selected,
  });
  final Function(String) onGenderChanged;
  final String? selected;

  final genderList = ['male', 'female', 'other'];
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedGender = useState<String?>(selected);
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      spacing: 12,
      children: genderList
          .map(
            (i) => GestureDetector(
              onTap: () {
                selectedGender.value = i;
                onGenderChanged(i);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFB0B0B0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i.capitalize(),
                      style: textTheme.bodySmall,
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedGender.value == i
                              ? primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      child: selectedGender.value == i
                          ? const Icon(
                              Icons.circle,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
