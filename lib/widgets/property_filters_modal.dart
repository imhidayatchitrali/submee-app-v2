import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:submee/providers/property_providers.dart';
import 'package:submee/widgets/switch_option.dart';

import '../generated/l10n.dart';
import '../providers/filter_provider.dart';
import '../utils/functions.dart';
import 'filter_label_option.dart';
import 'filter_number_stepper.dart';

class PropertyFilterModal extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = S.of(context);
    final propertyFilters = ref.watch(propertyFiltersProvider);
    final size = MediaQuery.sizeOf(context);
    final filters = ref.watch(filtersProvider);
    final textTheme = Theme.of(context).textTheme;
    final furnished = useState<bool?>(propertyFilters.furnished);
    final placeTypes = useState<List<int>>(propertyFilters.placeTypes);
    final bathrooms = useState<int>(propertyFilters.bathrooms ?? 0);
    final bedrooms = useState<int>(propertyFilters.bedrooms ?? 0);
    final selectedOptions = useState<List<String>>(propertyFilters.options);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          spacing: 14,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Unit type
            Text(
              locale.filter_unit_type,
              style: textTheme.labelMedium,
            ),
            filters.when(
              data: (data) => SizedBox(
                height: size.height * 0.25,
                child: GridView.count(
                  crossAxisCount: 2, // Number of columns
                  childAspectRatio: 3, // Adjust this to control the item's width/height ratio
                  crossAxisSpacing: 5, // Horizontal spacing between items
                  mainAxisSpacing: 10, // Vertical spacing between items
                  shrinkWrap: true, // Important if inside a scrollable view
                  children: data.types
                      .map(
                        (p) => FilterLabelOption(
                          name: getDatabaseItemNameTranslation(p.name, locale),
                          icon: p.icon,
                          isSelected: placeTypes.value.contains(p.id),
                          onTap: () {
                            final current = List<int>.from(placeTypes.value);
                            if (placeTypes.value.contains(p.id)) {
                              current.remove(p.id);
                            } else {
                              current.add(p.id);
                            }
                            placeTypes.value = current;
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
            ),

            // Furniture
            Text(
              locale.filter_furniture,
              style: textTheme.labelMedium,
            ),
            Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FilterLabelOption(
                    isSelected: furnished.value == true,
                    name: locale.filter_furnished,
                    icon: 'furnished',
                    onTap: () {
                      if (furnished.value == true) {
                        furnished.value = null;
                      } else {
                        furnished.value = true;
                      }
                    },
                  ),
                ),
                Expanded(
                  child: FilterLabelOption(
                    isSelected: furnished.value == false,
                    name: locale.filter_non_furnished,
                    icon: 'non_furnish',
                    onTap: () {
                      if (furnished.value == false) {
                        furnished.value = null;
                      } else {
                        furnished.value = false;
                      }
                    },
                  ),
                ),
              ],
            ),

            Text(
              locale.filter_bathroom,
              style: textTheme.labelMedium,
            ),
            FilterNumberStepper(
              initialValue: propertyFilters.bathrooms,
              onChanged: (value) {
                bathrooms.value = value;
              },
            ),
            Text(
              locale.filter_bedrooms,
              style: textTheme.labelMedium,
            ),
            FilterNumberStepper(
              initialValue: propertyFilters.bedrooms,
              onChanged: (value) {
                bedrooms.value = value;
              },
            ),

            SwitchOption(
              label: locale.filter_roommate,
              isSelected: selectedOptions.value.contains('roommates'),
              onChange: (val) {
                final current = List<String>.from(selectedOptions.value);
                if (val) {
                  current.add('roommates');
                } else {
                  current.remove('roommates');
                }
                selectedOptions.value = current;
              },
            ),
            SwitchOption(
              label: locale.filter_parking_spot,
              isSelected: selectedOptions.value.contains('parking_spot'),
              onChange: (val) {
                final current = List<String>.from(selectedOptions.value);
                if (val) {
                  current.add('parking_spot');
                } else {
                  current.remove('parking_spot');
                }
                selectedOptions.value = current;
              },
            ),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Get the current filters
                  final notifier = ref.read(propertyFiltersProvider.notifier);
                  // Update the provider
                  notifier.updateFilters(
                    furnished: furnished.value,
                    deleteFurnished: furnished.value == null,
                    placeTypes: placeTypes.value,
                    bathrooms: bathrooms.value,
                    bedrooms: bedrooms.value,
                    options: selectedOptions.value.isNotEmpty ? selectedOptions.value : null,
                  );

                  // Close the modal
                  Navigator.pop(context);
                },
                child: Text(
                  locale.apply_filters_button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
