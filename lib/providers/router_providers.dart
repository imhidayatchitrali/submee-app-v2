import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/config/router.dart';

import 'auth_provider.dart';

final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(
    authProvider: ref.watch(authProvider),
  );
});
