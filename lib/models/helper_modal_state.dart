import 'package:submee/models/helper_modal.dart';

class HelperModalState {
  HelperModalState({
    this.unseenHelpers = const [],
    this.isLoading = false,
    this.error,
    this.viewedHelperIds = const {},
  });
  final List<HelperModal> unseenHelpers;
  final bool isLoading;
  final String? error;
  final Set<int> viewedHelperIds;

  HelperModalState copyWith({
    List<HelperModal>? unseenHelpers,
    bool? isLoading,
    String? error,
    Set<int>? viewedHelperIds,
  }) {
    return HelperModalState(
      unseenHelpers: unseenHelpers ?? this.unseenHelpers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      viewedHelperIds: viewedHelperIds ?? this.viewedHelperIds,
    );
  }
}
