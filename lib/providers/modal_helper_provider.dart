import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/helper_modal.dart';
import 'package:submee/services/helper_service.dart';

import '../models/helper_modal_state.dart';

final helperModalProvider =
    StateNotifierProvider.autoDispose<HelperModalNotifier, HelperModalState>((ref) {
  final service = ref.watch(helperModalService);
  return HelperModalNotifier(service: service);
});

class HelperModalNotifier extends StateNotifier<HelperModalState> {
  HelperModalNotifier({
    required this.service,
  }) : super(HelperModalState()) {
    // Initial fetch
    fetchUnseenHelpers();
  }
  final HelperModalService service;

  // Fetch unseen helpers for the user
  Future<void> fetchUnseenHelpers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final helpers = await service.getUnseenHelpers();
      state = state.copyWith(
        unseenHelpers: helpers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setHelperAsSeen(HelperModal helper) {
    state = state.copyWith(
      viewedHelperIds: Set<int>.from(state.viewedHelperIds)..add(helper.id),
    );
  }

  // Mark a helper as seen
  Future<void> markHelperAsSeen(int helperId) async {
    try {
      await service.markHelperAsSeen(helperId);

      // Update local state
      final updatedHelpers = state.unseenHelpers.where((helper) => helper.id != helperId).toList();

      state = state.copyWith(
        unseenHelpers: updatedHelpers,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear session-based seen helpers (for testing or manual refresh)
  void clearSessionHelpers() {
    state = state.copyWith(viewedHelperIds: {});
  }

  // Force refresh helpers - useful when user completes actions that might trigger new helpers
  Future<void> refreshHelpers() async {
    // Preserve the existing viewedHelperIds
    final currentViewedIds = state.viewedHelperIds;

    // Fetch fresh helpers
    await fetchUnseenHelpers();

    // Restore the viewedHelperIds to maintain session state
    state = state.copyWith(viewedHelperIds: currentViewedIds);
  }

  // Get helper for specific route
  HelperModal? getHelperForRoute(String? routePath) {
    try {
      if (routePath == null) {
        return null;
      }

      // Find first active helper for this route that hasn't been seen this session
      return state.unseenHelpers.firstWhere(
        (helper) =>
            helper.routePath == routePath &&
            helper.isActive &&
            !state.viewedHelperIds.contains(helper.id),
      );
    } catch (e) {
      return null;
    }
  }

  bool hasSeenHelper(int helperId) {
    return state.viewedHelperIds.contains(helperId);
  }
}
