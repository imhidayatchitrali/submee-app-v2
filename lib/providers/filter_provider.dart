import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/services/config_service.dart';

import '../models/filter.dart';

final filtersProvider = FutureProvider<Filter>((ref) async {
  final filters = await ref.read(configService).getFilters();
  return filters;
});
