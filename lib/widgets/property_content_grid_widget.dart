import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/property.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

class PropertyContentGridWidget extends HookWidget {
  const PropertyContentGridWidget({
    super.key,
    required this.data,
    required this.onSelected,
    required this.selectedId,
    required this.multiple,
  });
  final List<PropertyItem> data;
  final Function(List<int>) onSelected;
  final List<int> selectedId;
  final bool multiple;
  @override
  Widget build(BuildContext context) {
    final selected = useState<List<int>>(selectedId);
    useEffect(
      () {
        selected.value = selectedId;
        return null;
      },
      [selectedId],
    );
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final isSelected = selected.value.contains(item.id);
        return GestureDetector(
          onTap: () {
            if (multiple) {
              if (selected.value.contains(item.id)) {
                selected.value = selected.value.where((e) => e != item.id).toList();
              } else {
                selected.value = [...selected.value, item.id];
              }
            } else {
              selected.value = [item.id];
            }
            onSelected(selected.value);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.black : const Color(0xFF323232).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSvgPicture('assets/icons/${item.icon}.svg'),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
