import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/location.dart';
import 'package:submee/services/config_service.dart';

final locationProvider = FutureProvider<List<LocationItem>>((ref) {
  return ref.read(configService).getLocations();
});
