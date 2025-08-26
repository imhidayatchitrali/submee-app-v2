import 'package:submee/models/property.dart';

class Filter {
  Filter({
    required this.types,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      types: (json['place_types'] as List)
          .map((e) => PropertyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<PropertyItem> types;
}
