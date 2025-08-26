import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/models/location.dart';

class PublishPlaceOnboardingLocation extends HookWidget {
  const PublishPlaceOnboardingLocation({
    super.key,
    required this.onLocationChange,
    required this.locations,
    required this.locationSelected,
    required this.onAddressChange,
    required this.addressSelected,
  });
  final Function(LocationItem) onLocationChange;
  final Function(String) onAddressChange;
  final List<LocationItem> locations;
  final LocationItem? locationSelected;
  final String? addressSelected;
  @override
  Widget build(BuildContext context) {
    final selectedLocation = useState<LocationItem>(
      locationSelected ?? locations.first,
    );
    useEffect(
      () {
        // This schedules the callback to run after the current frame is drawn
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Only call if locationSelected is null (first time initialization)
          if (locationSelected == null) {
            onLocationChange(selectedLocation.value);
          }
        });
        return null;
      },
      const [],
    );
    final selectedCountry = useState<int?>(selectedLocation.value.countryId);
    final addressInput = useState<String?>(addressSelected);
    final allCountries = locations.map((e) => e.countryId).toSet().toList();
    final allStates = locations
        .where((e) => e.countryId == selectedCountry.value)
        .map((e) => e.stateId)
        .where((e) => e != null)
        .toSet()
        .toList();

    useEffect(
      () {
        selectedLocation.value = locationSelected ?? locations.first;
        selectedCountry.value = selectedLocation.value.countryId;
        return null;
      },
      [locationSelected],
    );

    return SingleChildScrollView(
      child: Column(
        spacing: 34,
        children: [
          const SizedBox.shrink(),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            value: selectedLocation.value.countryId,
            items: allCountries.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  locations.firstWhere((element) => element.countryId == item).countryName,
                ),
              );
            }).toList(),
            onChanged: (value) {
              selectedCountry.value = value;
              selectedLocation.value = locations.firstWhere(
                (element) => element.countryId == value,
              );
              onLocationChange(selectedLocation.value);
            },
          ),
          if (allStates.isNotEmpty)
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              value: selectedLocation.value.countryId,
              items: allStates.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    locations.firstWhere((element) => element.stateId == item).stateName ?? '',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                selectedLocation.value = locations.firstWhere(
                  (element) =>
                      element.countryId == selectedCountry.value && element.stateId == value,
                );
                onLocationChange(selectedLocation.value);
              },
            ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: locations
                .where(
                  (e) =>
                      e.countryId == selectedCountry.value &&
                      (selectedLocation.value.stateId != null
                          ? e.stateId == selectedLocation.value.stateId
                          : true),
                )
                .map(
                  (item) => GestureDetector(
                    onTap: () {
                      selectedLocation.value = item;
                      onLocationChange(selectedLocation.value);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedLocation.value == item
                              ? Colors.black
                              : const Color(0xFF323232).withValues(alpha: 0.1),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.cityName),
                    ),
                  ),
                )
                .toList(),
          ),
          TextFormField(
            initialValue: addressInput.value,
            decoration: const InputDecoration(
              labelText: 'Street address',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onChanged: (value) {
              addressInput.value = value;
              onAddressChange(value);
            },
          ),
        ],
      ),
    );
  }
}
