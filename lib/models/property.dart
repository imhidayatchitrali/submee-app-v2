import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:submee/models/property_details.dart';
import 'package:submee/utils/enum.dart';

import 'location.dart';

class PropertyResult {
  PropertyResult({
    required this.properties,
    required this.resultCode,
  });

  factory PropertyResult.fromJson(Map<String, dynamic> json) {
    return PropertyResult(
      properties: (json['properties'] as List)
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList(),
      resultCode: fromString(json['result_code'] as String),
    );
  }

  static FiltersScenario fromString(String value) {
    switch (value) {
      case 'FILTERS_EMPTY':
        return FiltersScenario.filtersEmpty;
      case 'FILTERS_APPLIED':
        return FiltersScenario.filtersApplied;
      default:
        return FiltersScenario.filtersEmpty;
    }
  }

  final List<Property> properties;
  final FiltersScenario resultCode;
}

class Property {
  Property({
    required this.id,
    required this.price,
    required this.photos,
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.roommates,
    required this.size,
    required this.city,
    required this.country,
    required this.items,
    required this.hostName,
    required this.hostPhoto,
    this.parkingSpot,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      price: json['dates'][0]['price'].toString(),
      photos: (json['photos'] as List).map((e) => e as String).toList(),
      guests: json['max_guests'] as int,
      bedrooms: json['bedrooms'] as int,
      beds: json['beds'] as int,
      bathrooms: json['bathrooms'] as int,
      parkingSpot: json['parking_spot'] as bool?,
      roommates: json['roommates'] as int,
      size: json['size_sqm'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      items: (json['place_items'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hostName: json['host']['first_name'] == null && json['host']['last_name'] == null
          ? null
          : '${json['host']['first_name'] ?? ''} ${json['host']['last_name'] ?? ''}',
      hostPhoto: json['host']['photo_url'] as String?,
    );
  }
  final int id;
  final String price;
  final List<String> photos;
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final int roommates;
  final String size;
  final String city;
  final String country;
  final List<PropertyItem> items;
  final String? hostName;
  final String? hostPhoto;
  final bool? parkingSpot;
}

class PropertyItem extends Equatable {
  const PropertyItem({
    required this.id,
    required this.name,
    required this.icon,
  });
  factory PropertyItem.fromJson(Map<String, dynamic> json) {
    return PropertyItem(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }
  final int id;
  final String name;
  final String icon;

  @override
  List<Object?> get props => [id, name, icon];
}

class PropertyBasics {
  PropertyBasics({
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.roommates,
    required this.size,
    required this.parkingSpot,
  });

  factory PropertyBasics.fromPropertyDetails(PropertyDetails value) {
    return PropertyBasics(
      guests: value.guests,
      bedrooms: value.bedrooms,
      beds: value.beds,
      bathrooms: value.bathrooms,
      parkingSpot: value.parkingSpot,
      roommates: value.roommates,
      size: double.tryParse(value.size) ?? 0,
    );
  }

  const PropertyBasics.initial()
      : guests = 0,
        bedrooms = 0,
        beds = 0,
        bathrooms = 0,
        roommates = 0,
        parkingSpot = null,
        size = 0;

  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final int roommates;
  final double size;
  final bool? parkingSpot;

  PropertyBasics copyWith({
    int? guests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    int? roommates,
    bool? parkingSpot,
    double? size,
  }) {
    return PropertyBasics(
      guests: guests ?? this.guests,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      parkingSpot: parkingSpot ?? this.parkingSpot,
      roommates: roommates ?? this.roommates,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() => {
        'max_guests': guests,
        'bedrooms': bedrooms,
        'parking_spot': parkingSpot,
        'beds': beds,
        'bathrooms': bathrooms,
        'roommates': roommates,
        'size_sqm': size,
      };

  bool get isValid =>
      guests > 0 || bedrooms > 0 || beds > 0 || bathrooms > 0 || roommates > 0 || size > 0;
}

class PropertyInput {
  PropertyInput({
    required this.title,
    required this.description,
    required this.placeTypeId,
    required this.location,
    required this.basics,
    required this.stylesId,
    required this.amenitiesId,
    required this.rulesId,
    required this.photos,
    required this.address,
    required this.price,
    required this.lastMinuteOffer,
    required this.startDate,
    required this.endDate,
    required this.currentPhotos,
  });
  final String title;
  final String description;
  final int placeTypeId;
  final LocationItem location;
  final PropertyBasics basics;
  final List<int> stylesId;
  final List<int> amenitiesId;
  final List<int> rulesId;
  final List<File> photos;
  final List<String> currentPhotos;
  final String address;
  final double price;
  final bool lastMinuteOffer;
  final DateTime startDate;
  final DateTime endDate;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type_id': placeTypeId,
        'current_photos': currentPhotos,
        'location_item': location.toJson(),
        'basics': basics.toJson(),
        'styles_id': stylesId,
        'place_type_id': placeTypeId,
        'amenities_id': amenitiesId,
        'rules_id': rulesId,
        'address': address,
        'price': price,
        'last_minute_offer': lastMinuteOffer,
        'start_date': DateFormat('MM-dd-yyyy').format(startDate),
        'end_date': DateFormat('MM-dd-yyyy').format(endDate),
      };
}

class PropertyRequested {
  PropertyRequested({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.hostFirstName,
    required this.hostLastName,
    required this.hostPhoto,
    required this.location,
    required this.createdAt,
    required this.photos,
    required this.conversationId,
  });

  factory PropertyRequested.fromJson(Map<String, dynamic> json) {
    return PropertyRequested(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: RequestStatus.values
          .firstWhere((e) => e.name.toLowerCase() == json['status'].toString().toLowerCase()),
      hostFirstName: json['host']['first_name'] as String,
      hostLastName: json['host']['last_name'] as String,
      hostPhoto: json['host']['photo_url'] as String,
      location: json['location'] as String,
      createdAt: json['created_at'] as String,
      conversationId: json['conversation_id'] as int?,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
  final int id;
  final String title;
  final String description;
  final RequestStatus status;
  final String hostFirstName;
  final String hostLastName;
  final String hostPhoto;
  final String location;
  final String createdAt;
  final int? conversationId;
  final List<String> photos;
}

class PropertyDisplay {
  PropertyDisplay({
    required this.id,
    required this.title,
    required this.photos,
    required this.location,
  });

  factory PropertyDisplay.fromJson(Map<String, dynamic> json) {
    return PropertyDisplay(
      id: json['id'] as int,
      title: json['title'] as String,
      photos: (json['photos'] as List).map((e) => e as String).toList(),
      location: json['location'] as String,
    );
  }

  final int id;
  final String title;
  final List<String> photos;
  final String location;
}
