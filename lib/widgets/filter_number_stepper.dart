import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FilterNumberStepper extends HookWidget {
  const FilterNumberStepper({
    super.key,
    this.initialValue,
    this.onChanged,
  });
  final int? initialValue;
  final Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    final number = useState<int>(initialValue ?? 0);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (number.value > 0) {
              number.value--;
              if (onChanged != null) {
                onChanged!(number.value);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.remove,
              size: 25,
            ),
          ),
        ),
        Container(
          child: Text(
            number.value.toString(),
            style: textTheme.bodyLarge,
          ),
        ),
        InkWell(
          onTap: () {
            number.value++;
            if (onChanged != null) {
              onChanged!(number.value);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.add,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}
