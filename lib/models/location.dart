import 'package:equatable/equatable.dart';
import 'package:submee/models/property_details.dart';

class LocationItem extends Equatable {
  const LocationItem({
    required this.cityId,
    required this.countryId,
    required this.countryName,
    required this.cityName,
    required this.stateName,
    required this.stateId,
  });
  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      cityId: json['city_id'] as int,
      countryId: json['country_id'] as int,
      countryName: json['country_name'] as String,
      cityName: json['city_name'] as String,
      stateName: json['state_name'] as String?,
      stateId: json['state_id'] as int?,
    );
  }

  factory LocationItem.fromPropertyLocation(PropertyLocation location) {
    return LocationItem(
      cityId: location.cityId,
      countryId: location.countryId,
      countryName: location.country,
      cityName: location.city,
      stateName: location.state,
      stateId: location.stateId,
    );
  }

  const LocationItem.empty()
      : cityId = 0,
        countryId = 0,
        stateId = 0,
        stateName = '',
        countryName = '',
        cityName = '';

  Map<String, dynamic> toJson() {
    return {
      'city_id': cityId,
      'country_id': countryId,
      'country_name': countryName,
      'city_name': cityName,
      'state_name': stateName,
      'state_id': stateId,
    };
  }

  final int cityId;
  final int countryId;
  final String countryName;
  final String cityName;
  final String? stateName;
  final int? stateId;

  @override
  List<Object?> get props => [
        cityId,
        countryId,
        countryName,
        cityName,
        stateName,
        stateId,
      ];
}
