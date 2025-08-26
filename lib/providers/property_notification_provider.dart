import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/property.dart';
import 'package:submee/utils/enum.dart';

import '../services/property_service.dart';

final propertyNotificationsProvider = StateNotifierProvider.autoDispose<
    PropertyNotificationsNotifier, AsyncValue<List<PropertyRequested>>>((ref) {
  return PropertyNotificationsNotifier(ref);
});

class PropertyNotificationsNotifier extends StateNotifier<AsyncValue<List<PropertyRequested>>> {
  PropertyNotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchProperties();
  }
  final Ref ref;

  // Fetch properties from the service
  Future<void> fetchProperties([RequestStatus? status]) async {
    try {
      state = const AsyncValue.loading();
      final properties = await ref.read(propertyService).getPropertiesForNotifications(status);
      state = AsyncValue.data(properties);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Refresh the state with new data
  Future<void> refresh() async {
    await fetchProperties();
  }

  Future<void> filterByTab(int index) async {
    RequestStatus? statusToFilter;
    switch (index) {
      case 1:
        statusToFilter = RequestStatus.approved;
        break;
      case 2:
        statusToFilter = RequestStatus.pending;
        break;
      default:
    }
    await fetchProperties(statusToFilter);
  }

  // Withdraw a property request
  Future<void> withdrawPropertyRequest(int propertyId) async {
    try {
      // Update the local state by removing the withdrawn property
      state.whenData((properties) {
        state = AsyncValue.data(
          properties.where((property) => property.id != propertyId).toList(),
        );
      });
      // Call the service to withdraw the request
      await ref.read(propertyService).withdrawPropertyRequest(propertyId);
    } catch (error, stackTrace) {
      // Keep the current state but report the error
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
