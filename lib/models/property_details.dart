import 'dart:convert';

import 'property.dart';

class PropertyDetails extends Property {
  PropertyDetails({
    required super.id,
    required super.price,
    required super.photos,
    required super.guests,
    required super.bedrooms,
    required super.beds,
    required super.bathrooms,
    required super.roommates,
    required super.size,
    required super.city,
    required super.country,
    required super.items,
    required super.hostName,
    required super.hostPhoto,
    required this.title,
    required this.description,
    required this.rules,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.host,
    required this.dates,
    required this.lastMinuteEnabled,
    required this.placeTypeId,
    required this.ammenities,
    required this.styles,
  });

  factory PropertyDetails.fromJson(Map<String, dynamic> json) {
    return PropertyDetails(
      id: json['id'] as int,
      price: json['dates'][0]['price'].toString(),
      photos: (json['photos'] as List).map((e) => e as String).toList(),
      guests: json['max_guests'] as int,
      bedrooms: json['bedrooms'] as int,
      beds: json['beds'] as int,
      bathrooms: json['bathrooms'] as int,
      roommates: json['roommates'] as int,
      size: json['size_sqm'] as String,
      city: json['location']['city'] as String,
      country: json['location']['country'] as String,
      items: (json['place_items'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hostName: json['host']['first_name'] == null && json['host']['last_name'] == null
          ? null
          : '${json['host']['first_name'] ?? ''} ${json['host']['last_name'] ?? ''}',
      hostPhoto: json['host']['photo_url'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      rules: (json['rules'] as List).map((e) => e['id'] as int).toList(),
      styles: (json['style_ids'] as List).map((e) => e as int).toList(),
      rating: (json['rating'] as num).toDouble(),
      reviews: (json['reviews'] as List)
          .map((e) => PropertyReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: PropertyLocation.fromJson(json['location'] as Map<String, dynamic>),
      host: PropertyHost.fromJson(json['host'] as Map<String, dynamic>),
      dates: (json['dates'] as List)
          .map((e) => PropertyDate.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMinuteEnabled: json['last_minute_enabled'] as bool,
      placeTypeId: json['place_type_id'] as int,
      ammenities: (json['amenity_ids'] as List).map((e) => e as int).toList(),
    );
  }

  final String title;
  final String description;
  final bool lastMinuteEnabled;
  final int placeTypeId;
  final List<int> rules;
  final List<int> ammenities;
  final List<int> styles;
  final double rating;
  final List<PropertyReview> reviews;
  final PropertyLocation location;
  final PropertyHost host;
  final List<PropertyDate> dates;
}

class PropertyReview {
  PropertyReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: PropertyReviewUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final int id;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final PropertyReviewUser user;
}

class PropertyReviewUser {
  PropertyReviewUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  factory PropertyReviewUser.fromJson(Map<String, dynamic> json) {
    return PropertyReviewUser(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final int id;
  final String firstName;
  final String lastName;
  final String? photoUrl;

  String get fullName => '$firstName $lastName';
}

class PropertyLocation {
  PropertyLocation({
    required this.address,
    required this.city,
    required this.country,
    required this.coordinates,
    required this.state,
    required this.stateId,
    required this.cityId,
    required this.countryId,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    final coordinatesJson = json['coordinates'] is String
        ? jsonDecode(json['coordinates'] as String)
        : json['coordinates'];

    return PropertyLocation(
      address: json['address'] as String,
      coordinates: coordinatesJson == null
          ? null
          : GeoPoint(
              latitude: (coordinatesJson['coordinates'][1] as num).toDouble(),
              longitude: (coordinatesJson['coordinates'][0] as num).toDouble(),
            ),
      city: json['city'] as String,
      country: json['country'] as String,
      state: json['state'] as String?,
      stateId: json['state_id'] as int?,
      cityId: json['city_id'] as int,
      countryId: json['country_id'] as int,
    );
  }

  final String address;
  final GeoPoint? coordinates;
  final String city;
  final String country;
  final String? state;
  final int? stateId;
  final int cityId;
  final int countryId;
}

class PropertyHost {
  PropertyHost({
    required this.id,
    required this.photoUrl,
    required this.firstName,
    required this.lastName,
    required this.bio,
  });

  factory PropertyHost.fromJson(Map<String, dynamic> json) {
    return PropertyHost(
      id: json['id'] as int,
      photoUrl: json['photo_url'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      bio: json['bio'] as String?,
    );
  }

  final int id;
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final String? bio;

  String get fullName => '$firstName $lastName';
}

class PropertyDate {
  PropertyDate({
    required this.startDate,
    required this.endDate,
    required this.price,
  });

  factory PropertyDate.fromJson(Map<String, dynamic> json) {
    return PropertyDate(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }

  final DateTime startDate;
  final DateTime endDate;
  final double price;
}

class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}
