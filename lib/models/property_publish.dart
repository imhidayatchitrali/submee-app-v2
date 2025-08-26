import 'dart:io';

import 'package:submee/constant.dart';
import 'package:submee/models/location.dart';
import 'package:submee/models/property.dart';
import 'package:submee/models/property_details.dart';
import 'package:submee/utils/enum.dart';

class PropertyPublishData {
  PropertyPublishData({
    required this.propertyPublishDetails,
    required this.propertyData,
    this.step = PropertyPublishOnboardingStep.placeDate,
    this.transactionStatus = TransactionStatus.idle,
    this.propertyId,
  });

  final PropertyPublishDetails propertyPublishDetails;
  final PropertyPublishOnboardingStep step;
  final PropertyData propertyData;
  final TransactionStatus transactionStatus;
  final int? propertyId;

  PropertyPublishData copyWith({
    PropertyPublishDetails? propertyPublishDetails,
    PropertyPublishOnboardingStep? step,
    PropertyData? propertyData,
    TransactionStatus? transactionStatus,
    int? propertyId,
  }) {
    return PropertyPublishData(
      propertyPublishDetails: propertyPublishDetails ?? this.propertyPublishDetails,
      step: step ?? this.step,
      propertyData: propertyData ?? this.propertyData,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}

class PropertyData {
  PropertyData({
    required this.styles,
    required this.type,
    required this.amenities,
    required this.rules,
    required this.locations,
  });

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    return PropertyData(
      styles: (json['styles'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: (json['types'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenities: (json['amenities'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rules: (json['rules'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      locations: (json['locations'] as List).map((e) {
        return LocationItem.fromJson(e as Map<String, dynamic>);
      }).toList(),
    );
  }
  final List<PropertyItem> styles;
  final List<PropertyItem> type;
  final List<PropertyItem> amenities;
  final List<PropertyItem> rules;
  final List<LocationItem> locations;
}

class PropertyPublishDetails {
  PropertyPublishDetails({
    this.title,
    this.description,
    this.placeTypeId,
    this.basics = const PropertyBasics.initial(),
    this.amenitiesId = const [],
    this.stylesId = const [],
    this.rulesId = const [],
    this.photos = const [],
    this.address,
    this.price = defaultPrice,
    this.startDate,
    this.endDate,
    this.location,
    this.currentPhotos = const [],
    this.lastMinuteEnabled = false,
  });

  factory PropertyPublishDetails.fromPropertyDetails(
    PropertyDetails propertyDetails,
  ) {
    return PropertyPublishDetails(
      title: propertyDetails.title,
      description: propertyDetails.description,
      placeTypeId: propertyDetails.placeTypeId,
      amenitiesId: propertyDetails.ammenities,
      stylesId: propertyDetails.styles,
      rulesId: propertyDetails.rules,
      basics: PropertyBasics.fromPropertyDetails(propertyDetails),
      currentPhotos: propertyDetails.photos.map((e) => e).toList(),
      photos: [],
      address: propertyDetails.location.address,
      price: double.parse(propertyDetails.price.toString()),
      startDate: propertyDetails.dates.isNotEmpty ? propertyDetails.dates.first.startDate : null,
      endDate: propertyDetails.dates.isNotEmpty ? propertyDetails.dates.first.endDate : null,
      lastMinuteEnabled: propertyDetails.lastMinuteEnabled,
      location: LocationItem.fromPropertyLocation(propertyDetails.location),
    );
  }
  final String? title;
  final String? description;
  final int? placeTypeId;
  final List<int> amenitiesId;
  final List<int> stylesId;
  final List<int> rulesId;
  final PropertyBasics basics;
  final List<File> photos;
  final String? address;
  final double price;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool lastMinuteEnabled;
  final LocationItem? location;
  final List<String> currentPhotos;

  PropertyPublishDetails copyWith({
    String? title,
    String? description,
    int? placeTypeId,
    List<int>? amenitiesId,
    List<int>? stylesId,
    List<int>? rulesId,
    PropertyBasics? basics,
    List<File>? photos,
    List<String>? currentPhotos,
    int? cityId,
    String? address,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    bool? lastMinuteEnabled,
    LocationItem? location,
    bool removeDates = false,
  }) {
    return PropertyPublishDetails(
      title: title ?? this.title,
      description: description ?? this.description,
      placeTypeId: placeTypeId ?? this.placeTypeId,
      amenitiesId: amenitiesId ?? this.amenitiesId,
      basics: basics ?? this.basics,
      photos: photos ?? this.photos,
      stylesId: stylesId ?? this.stylesId,
      rulesId: rulesId ?? this.rulesId,
      address: address ?? this.address,
      price: price ?? this.price,
      startDate: removeDates ? null : startDate ?? this.startDate,
      endDate: removeDates ? null : endDate ?? this.endDate,
      lastMinuteEnabled: lastMinuteEnabled ?? this.lastMinuteEnabled,
      location: location ?? this.location,
      currentPhotos: currentPhotos ?? this.currentPhotos,
    );
  }
}
