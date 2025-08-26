import 'package:intl/intl.dart';

class PropertyFilters {
  PropertyFilters({
    this.locationList,
    this.options = const [],
    this.minPrice,
    this.maxPrice,
    this.startDate,
    this.endDate,
    this.bathrooms,
    this.bedrooms,
    this.placeTypes = const [],
    this.furnished,
  });

  PropertyFilters.defaultValues()
      : locationList = [],
        options = [],
        minPrice = null,
        maxPrice = null,
        startDate = null,
        endDate = null,
        bathrooms = null,
        bedrooms = null,
        placeTypes = [],
        furnished = null;
  factory PropertyFilters.fromJson(Map<String, dynamic> json) => PropertyFilters(
        locationList: (json['location_list'] as List? ?? []).map((e) => e as int).toList(),
        options: (json['options'] as List? ?? []).map((e) => e as String).toList(),
        minPrice: json['min_price'],
        maxPrice: json['max_price'],
        startDate: json['date_start'] != null ? DateTime.parse(json['date_start']) : null,
        endDate: json['date_end'] != null ? DateTime.parse(json['date_end']) : null,
        bathrooms: json['bathroom'],
        bedrooms: json['bedrooms'],
        placeTypes: (json['place_types'] as List? ?? []).map((e) => e as int).toList(),
        furnished: json['furnished'],
      );

  PropertyFilters copyWith({
    List<int>? locationList,
    List<String>? options,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool deleteDates = false,
    bool deleteFurnished = false,
    bool deletePrices = false,
    int? bathrooms,
    int? bedrooms,
    List<int>? placeTypes,
    bool? furnished,
  }) {
    return PropertyFilters(
      locationList: locationList ?? this.locationList,
      options: options ?? this.options,
      startDate: deleteDates ? null : startDate ?? this.startDate,
      endDate: deleteDates ? null : endDate ?? this.endDate,
      minPrice: deletePrices ? null : minPrice ?? this.minPrice,
      maxPrice: deletePrices ? null : maxPrice ?? this.maxPrice,
      bathrooms: bathrooms ?? bathrooms,
      bedrooms: bedrooms ?? this.bedrooms,
      placeTypes: placeTypes ?? this.placeTypes,
      furnished: deleteFurnished ? null : furnished ?? this.furnished,
    );
  }

  final List<int>? locationList;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? bathrooms;
  final int? bedrooms;
  final List<int> placeTypes;
  final List<String> options;
  final bool? furnished;

  Map<String, dynamic> toJson() => {
        'location_list': locationList,
        'options': options,
        'min_price': minPrice,
        'max_price': maxPrice,
        'date_start': startDate?.toIso8601String(),
        'date_end': endDate?.toIso8601String(),
        'bathrooms': bathrooms,
        'bedrooms': bedrooms,
        'place_types': placeTypes,
        'furnished': furnished,
      };

  String queryParam() {
    final params = <String>[];
    if (locationList != null && locationList!.isNotEmpty) {
      params.add('city_ids=${locationList!.join(',')}');
    }
    if (minPrice != null) {
      params.add('min_price=$minPrice');
    }
    if (maxPrice != null) {
      params.add('max_price=$maxPrice');
    }
    if (startDate != null) {
      params.add('date_start=${startDate!.millisecondsSinceEpoch}');
    }
    if (endDate != null) {
      params.add('date_end=${endDate!.millisecondsSinceEpoch}');
    }
    if (bathrooms != null) {
      params.add('bathrooms=$bathrooms');
    }
    if (bedrooms != null) {
      params.add('bedrooms=$bedrooms');
    }
    if (options.isNotEmpty) {
      params.add('options=${options.join(',')}');
    }
    if (placeTypes.isNotEmpty) {
      params.add('place_types=${placeTypes.join(',')}');
    }
    if (furnished != null) {
      params.add('furnished=$furnished');
    }
    if (params.isEmpty) {
      return '';
    }
    final query = params.join('&');
    return '?$query';
  }

  bool get isEmpty {
    return options.isEmpty &&
        minPrice == null &&
        maxPrice == null &&
        startDate == null &&
        endDate == null &&
        (bathrooms == null || bathrooms == 0) &&
        (bedrooms == null || bedrooms == 0) &&
        placeTypes.isEmpty &&
        furnished == null;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  String? get priceLabel {
    if (minPrice == null && maxPrice == null) {
      return null;
    }
    return '${minPrice != null ? minPrice!.toStringAsFixed(0) : '0'} - ${maxPrice != null ? maxPrice!.toStringAsFixed(0) : '0'}';
  }

  String? get dateLabel {
    if (startDate == null && endDate == null) {
      return null;
    }

    final dateFormatter = DateFormat('MMM d');
    final startFormatted = startDate != null ? dateFormatter.format(startDate!) : '';

    // For the end date, we'll check if it's in the same month as the start date
    String endFormatted = '';
    if (endDate != null) {
      if (startDate != null &&
          startDate!.month == endDate!.month &&
          startDate!.year == endDate!.year) {
        // If same month, just show the day
        endFormatted = DateFormat('d').format(endDate!);
      } else {
        // If different month, show month and day
        endFormatted = dateFormatter.format(endDate!);
      }
    }

    return '$startFormatted - $endFormatted';
  }
}
