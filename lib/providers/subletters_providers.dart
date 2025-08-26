import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/preferences.dart';

import '../models/sublet.dart';
import '../models/sublet_filters.dart';
import '../services/user_service.dart';

final sublettersProvider =
    AsyncNotifierProvider.autoDispose<SubletNotifier, SubletNotifierState>(() {
  return SubletNotifier();
});

class SubletNotifier extends AutoDisposeAsyncNotifier<SubletNotifierState> {
  @override
  Future<SubletNotifierState> build() async {
    final filters = ref.watch(subletFiltersProvider);
    return await ref.read(userService).getUserSubletters(filters);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Get the latest filters when refreshing
      final filters = ref.read(subletFiltersProvider);
      final result = await ref.read(userService).getUserSubletters(filters);
      return result;
    });
  }
}

final subletFiltersProvider = StateNotifierProvider<SubletFiltersNotifier, SubletFilters>((ref) {
  return SubletFiltersNotifier();
});

class SubletFiltersNotifier extends StateNotifier<SubletFilters> {
  SubletFiltersNotifier() : super(Preferences.getSubletFilters());

  void updateFilters({
    List<int>? locationList,
  }) {
    final newState = state.copyWith(
      locationList: locationList,
    );

    // Only update state if something actually changed
    if (newState != state) {
      state = newState;
      Preferences.saveSubletFilters(state);
    }
  }
}
