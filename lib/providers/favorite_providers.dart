import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/property.dart';
import 'package:submee/models/user.dart';

import '../services/property_service.dart';
import '../services/user_service.dart';
import '../utils/enum.dart';

final approvedPropertyRequestedProvider =
    FutureProvider.autoDispose<List<PropertyRequested>>((ref) {
  return ref.read(propertyService).getPropertiesForNotifications(RequestStatus.approved);
});

final approvedUserRequestedProvider = FutureProvider.autoDispose<List<UserRequested>>((ref) {
  return ref.read(userService).getUsersForNotifications(RequestStatus.approved);
});
