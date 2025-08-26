import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/l10n.dart';
import '../models/location.dart';
import '../providers/location_provider.dart';

class LocationListModal extends ConsumerStatefulWidget {
  const LocationListModal({
    super.key,
    this.initialSelectedCityIds,
    this.onSelectedCities,
  });
  final List<int>? initialSelectedCityIds;
  final Function(List<int>)? onSelectedCities;
  @override
  ConsumerState<LocationListModal> createState() => _LocationListModalState();
}

class _LocationListModalState extends ConsumerState<LocationListModal> {
  // Track expanded countries and states
  final Map<int, bool> _expandedCountries = {};
  final Map<int, bool> _expandedStates = {};

  // Track selected cities
  late Set<int> _selectedCityIds;

  @override
  void initState() {
    super.initState();
    // Initialize selected cities with any initial values
    _selectedCityIds =
        widget.initialSelectedCityIds != null ? Set.from(widget.initialSelectedCityIds!) : {};
  }

  @override
  Widget build(BuildContext context) {
    final locationProv = ref.watch(locationProvider);
    final locale = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Location list
          Expanded(
            child: locationProv.when(
              data: (locations) {
                // Group locations by country
                final Map<int, _CountryGroup> countriesMap = {};

                for (final location in locations) {
                  if (!countriesMap.containsKey(location.countryId)) {
                    countriesMap[location.countryId] = _CountryGroup(
                      countryId: location.countryId,
                      countryName: location.countryName,
                      states: {},
                      cities: [],
                    );
                  }

                  final countryGroup = countriesMap[location.countryId]!;

                  // Check if this location has state information
                  if (location.stateId != null) {
                    // Add to state group
                    if (!countryGroup.states.containsKey(location.stateId)) {
                      countryGroup.states[location.stateId!] = _StateGroup(
                        stateId: location.stateId!,
                        stateName: location.stateName!,
                        cities: [],
                      );
                    }
                    countryGroup.states[location.stateId]!.cities.add(location);
                  } else {
                    // No state, add directly to country's cities
                    countryGroup.cities.add(location);
                  }
                }

                final countries = countriesMap.values.toList();

                return ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    return _buildCountryItem(context, countries[index]);
                  },
                );
              },
              error: (error, stack) => Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (widget.onSelectedCities != null) {
                  widget.onSelectedCities!(_selectedCityIds.toList());
                }
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                locale.apply_button,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(BuildContext context, _CountryGroup country) {
    final isExpanded = _expandedCountries[country.countryId] ?? false;
    final hasChildren = country.states.isNotEmpty || country.cities.isNotEmpty;
    final textTheme = TextTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country item
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                _expandedCountries[country.countryId] = !isExpanded;
              });
            } else {
              // If country has no children, select it directly
              _toggleCitySelection(country.cities.first);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  country.countryName,
                  style: textTheme.displaySmall,
                ),
                if (hasChildren)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_outlined
                          : Icons.keyboard_arrow_down_outlined,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Show children if expanded
        if (isExpanded) ...[
          // If the country has states, show them
          if (country.states.isNotEmpty)
            ...country.states.values.map((state) => _buildStateItem(context, state)).toList(),

          // If the country has direct cities (no states), show them
          if (country.cities.isNotEmpty)
            ...country.cities
                .map((city) => _buildCityItem(context, city, isDirectCity: true))
                .toList(),
        ],
      ],
    );
  }

  Widget _buildStateItem(BuildContext context, _StateGroup state) {
    final isExpanded = _expandedStates[state.stateId] ?? false;
    final textTheme = TextTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedStates[state.stateId] = !isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.stateName,
                  style: textTheme.labelMedium,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                  ),
                ),
              ],
            ),
          ),

          // Show cities if state is expanded
          if (isExpanded) ...state.cities.map((city) => _buildCityItem(context, city)).toList(),
        ],
      ),
    );
  }

  Widget _buildCityItem(BuildContext context, LocationItem city, {bool isDirectCity = false}) {
    final isSelected = _selectedCityIds.contains(city.cityId);
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: () => _toggleCitySelection(city),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('${city.cityName}, ${city.stateName ?? city.countryName}')),
            Checkbox(
              checkColor: Colors.white,
              activeColor: primaryColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(
                color: Colors.grey, // Gray border color
                width: 1.5, // Border width
              ),
              value: isSelected,
              onChanged: (_) {
                _toggleCitySelection(city);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCitySelection(LocationItem location) {
    setState(() {
      if (_selectedCityIds.contains(location.cityId)) {
        _selectedCityIds.remove(location.cityId);
      } else {
        _selectedCityIds.add(location.cityId);
      }
    });
  }
}

// Helper classes for grouping data
class _CountryGroup {
  // Cities directly under country (no state)

  _CountryGroup({
    required this.countryId,
    required this.countryName,
    required this.states,
    required this.cities,
  });
  final int countryId;
  final String countryName;
  final Map<int, _StateGroup> states;
  final List<LocationItem> cities;
}

class _StateGroup {
  _StateGroup({
    required this.stateId,
    required this.stateName,
    required this.cities,
  });
  final int stateId;
  final String stateName;
  final List<LocationItem> cities;
}
