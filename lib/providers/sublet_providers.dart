import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/user.dart';

import '../services/user_service.dart';

final subletDetailProvider = FutureProvider.family.autoDispose<UserProfile, int>((ref, id) {
  return ref.read(userService).getUserSubletDetail(id);
});
