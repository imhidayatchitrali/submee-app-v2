import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/property.dart';
import 'package:submee/models/property_details.dart';
import 'package:submee/utils/custom_toast.dart';
import 'package:submee/utils/enum.dart';
import 'package:submee/utils/preferences.dart';

import '../models/property_filters.dart';
import '../services/property_service.dart';

final propertyFiltersProvider =
    StateNotifierProvider<PropertyFiltersNotifier, PropertyFilters>((ref) {
  return PropertyFiltersNotifier();
});

class PropertyFiltersNotifier extends StateNotifier<PropertyFilters> {
  PropertyFiltersNotifier() : super(Preferences.getPropertyFilters());

  void updateFilters({
    List<int>? locationList,
    List<String>? options,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool deleteDates = false,
    bool deletePrices = false,
    bool deleteFurnished = false,
    int? bathrooms,
    int? bedrooms,
    List<int>? placeTypes,
    bool? furnished,
  }) {
    final newState = state.copyWith(
      locationList: locationList,
      options: options,
      minPrice: minPrice,
      maxPrice: maxPrice,
      startDate: startDate,
      endDate: endDate,
      deleteDates: deleteDates,
      deletePrices: deletePrices,
      deleteFurnished: deleteFurnished,
      bathrooms: bathrooms,
      bedrooms: bedrooms,
      placeTypes: placeTypes,
      furnished: furnished,
    );

    // Only update state if something actually changed
    if (newState != state) {
      state = newState;
      Preferences.savePropertyFilters(state);
      // Note: No need to manually trigger property loading here.
      // The properties provider is watching this provider and will react automatically
    }
  }
}

final hostPropertiesProvider = FutureProvider.autoDispose<List<PropertyDisplay>>((ref) {
  return ref.read(propertyService).getHostProperties();
});

final propertyDetailProvider = FutureProvider.family.autoDispose<PropertyDetails, int>((ref, id) {
  return ref.read(propertyService).getPropertyDetail(id);
});

final propertiesProvider = AsyncNotifierProvider<PropertiesNotifier, List<Property>>(() {
  return PropertiesNotifier();
});

class PropertiesNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() async {
    // Watch the filters provider to react to changes
    ref.listen(propertyFiltersProvider, (previous, current) {
      // Only reload if this isn't the initial build and filters actually changed
      if (previous != null && previous != current) {
        loadProperties(refresh: true);
      }
    });
    // Load properties immediately when the provider is first accessed
    _loadInitialProperties();
    // Return empty list initially while loading
    return [];
  }

  Future<void> _loadInitialProperties() async {
    // Get filters from the filter provider
    final filters = ref.read(propertyFiltersProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final propertyResult = await ref.read(propertyService).getProperties(filters);

      // Handle the result message
      late final String message;
      final resultCode = propertyResult.resultCode;
      switch (resultCode) {
        case FiltersScenario.filtersEmpty:
          message = 'Results from filters empty';
          break;
        case FiltersScenario.filtersApplied:
          message = 'Results from filters applied';
          break;
      }
      ref.read(customToastProvider).show(message);

      return propertyResult.properties;
    });
  }

  Future<void> loadProperties({bool refresh = false}) async {
    // Use state.value to get current state without triggering a rebuild
    final currentProperties = state.value ?? [];

    // Only show loading state when we don't have data
    if (currentProperties.isEmpty) {
      state = const AsyncValue.loading();
    }

    // Get filters from the filter provider
    final filters = ref.read(propertyFiltersProvider);

    state = await AsyncValue.guard(() async {
      try {
        final propertyResult = await ref.read(propertyService).getProperties(filters);

        // Handle the result message
        late final String message;
        final resultCode = propertyResult.resultCode;
        switch (resultCode) {
          case FiltersScenario.filtersEmpty:
            message = 'Results from filters empty';
            break;
          case FiltersScenario.filtersApplied:
            message = 'Results from filters applied';
            break;
        }
        ref.read(customToastProvider).show(message);

        // If it's a refresh, replace the list; otherwise, keep the current list
        if (refresh) {
          return propertyResult.properties;
        } else {
          // Return the combination of existing and new properties
          final newProperties = propertyResult.properties;
          // You might want to add deduplication logic here if needed
          return [...currentProperties, ...newProperties];
        }
      } catch (e) {
        // Log the error but don't lose the current data
        ref.read(customToastProvider).show('Error loading properties');
        // Return current properties to avoid UI reset
        return currentProperties;
      }
    });
  }

  // Add a method to load more properties (for pagination)
  Future<void> loadMoreProperties() async {
    // Implement pagination logic here
    // Similar to loadProperties but with pagination parameters
  }
}

final deletePropertyProvider = Provider.autoDispose((ref) {
  return (int propertyId) async {
    await ref.read(propertyService).deleteProperty(propertyId);
    ref.invalidate(hostPropertiesProvider);
  };
});
