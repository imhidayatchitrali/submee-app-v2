import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/enum.dart';

import '../models/user.dart';
import '../services/property_service.dart';
import '../services/user_service.dart';

final userNotificationsProvider =
    StateNotifierProvider.autoDispose<UserNotificationsNotifier, AsyncValue<List<UserRequested>>>(
        (ref) {
  return UserNotificationsNotifier(ref);
});

class UserNotificationsNotifier extends StateNotifier<AsyncValue<List<UserRequested>>> {
  UserNotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchUsers();
  }
  final Ref ref;

  // Fetch properties from the service
  Future<void> fetchUsers([RequestStatus? status]) async {
    try {
      state = const AsyncValue.loading();
      final items = await ref.read(userService).getUsersForNotifications(status);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Refresh the state with new data
  Future<void> refresh() async {
    await fetchUsers();
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
    await fetchUsers(statusToFilter);
  }

  // Withdraw a property request
  Future<void> withdrawPropertyRequest(int propertyId) async {
    try {
      // Update the local state by removing the withdrawn property
      state.whenData((users) {
        state = AsyncValue.data(
          users.where((user) => user.propertyId != propertyId).toList(),
        );
      });
      // Call the service to withdraw the request
      await ref.read(propertyService).withdrawPropertyRequest(propertyId);
    } catch (error, stackTrace) {
      // Keep the current state but report the error
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> declineUserRequest(int userId, int propertyId) async {
    try {
      // Update the local state by removing the withdrawn property
      state.whenData((users) {
        state = AsyncValue.data(
          users.where((user) => user.propertyId != propertyId).toList(),
        );
      });
      // Call the service to withdraw the request
      await ref.read(userService).declineUserRequest(userId, propertyId);
    } catch (error, stackTrace) {
      // Keep the current state but report the error
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> approveUserRequest(int userId, int propertyId) async {
    try {
      // Call the service to withdraw the request
      final result = await ref.read(userService).approveUserRequest(userId, propertyId);
      state.whenData((users) {
        state = AsyncValue.data(
          users.map((user) {
            if (user.propertyId == result.propertyId) {
              return result;
            }
            return user;
          }).toList(),
        );
      });
    } catch (error, stackTrace) {
      // Keep the current state but report the error
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
