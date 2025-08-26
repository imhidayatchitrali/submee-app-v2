import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

import '../models/geo_location.dart';
import '../utils/logger.dart';

final locationService = Provider<LocationService>((ref) {
  final service = LocationService(
    location: Location(),
  );
  return service;
});

class LocationService {
  LocationService({
    required this.location,
  });

  GeoLocation? _currentLocation;
  final Location location;

  Future<GeoLocation?> getLocation() async {
    try {
      final loc = await location.getLocation();
      if (loc.latitude == null || loc.longitude == null) {
        return null;
      }
      _currentLocation = GeoLocation(
        latitude: loc.latitude!,
        longitude: loc.longitude!,
      );
      return _currentLocation!;
    } on Exception catch (e) {
      Logger.e('Could not get location: ${e.toString()}');
      return null;
    }
  }
}
