import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/widgets/custom_svg_picture.dart';

import '../models/property.dart';

class PublishPlaceOnboardingStyle extends HookWidget {
  const PublishPlaceOnboardingStyle({
    super.key,
    required this.onChangeItems,
    required this.onChangeExtras,
    required this.itemsSelected,
    required this.extraItemsSelected,
    required this.items,
    required this.extras,
    required this.extraTitle,
  });
  final Function(List<int>) onChangeItems;
  final Function(List<int>) onChangeExtras;
  final List<int> itemsSelected;
  final List<int> extraItemsSelected;
  final List<PropertyItem> items;
  final List<PropertyItem> extras;
  final String extraTitle;
  @override
  Widget build(BuildContext context) {
    final itemsEditable = useState<List<int>>([...itemsSelected]);
    final extrasEditable = useState<List<int>>([...extraItemsSelected]);
    final textTheme = Theme.of(context).textTheme;

    useEffect(
      () {
        itemsEditable.value = [...itemsSelected];
        extrasEditable.value = [...extraItemsSelected];
        return null;
      },
      [itemsSelected, extraItemsSelected],
    );

    return Container(
      padding: const EdgeInsets.only(top: 24),
      child: SingleChildScrollView(
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 22,
              children: items
                  .map(
                    (feature) => FeatureChip(
                      item: feature,
                      selected: itemsEditable.value.contains(feature.id),
                      onSelect: (id) {
                        if (itemsEditable.value.contains(id)) {
                          itemsEditable.value.remove(id);
                        } else {
                          itemsEditable.value.add(id);
                        }
                        onChangeItems(itemsEditable.value);
                      },
                    ),
                  )
                  .toList(),
            ),
            Column(
              spacing: 21,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  extraTitle,
                  style: textTheme.displayMedium,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 22,
                  children: extras
                      .map(
                        (feature) => FeatureChip(
                          item: feature,
                          selected: extrasEditable.value.contains(feature.id),
                          onSelect: (id) {
                            if (extrasEditable.value.contains(id)) {
                              extrasEditable.value.remove(id);
                            } else {
                              extrasEditable.value.add(id);
                            }
                            onChangeExtras(extrasEditable.value);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    super.key,
    required this.item,
    required this.selected,
    required this.onSelect,
  });
  final PropertyItem item;
  final bool selected;
  final Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.black : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvgPicture('assets/icons/${item.icon}.svg'),
            const SizedBox(width: 8),
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
  }
}
