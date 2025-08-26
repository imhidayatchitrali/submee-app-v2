class SubletFilters {
  SubletFilters({
    this.locationList,
  });

  SubletFilters.defaultValues() : locationList = [];

  factory SubletFilters.fromJson(Map<String, dynamic> json) => SubletFilters(
        locationList: (json['location_list'] as List? ?? []).map((e) => e as int).toList(),
      );

  SubletFilters copyWith({
    List<int>? locationList,
  }) {
    return SubletFilters(
      locationList: locationList ?? this.locationList,
    );
  }

  final List<int>? locationList;

  Map<String, dynamic> toJson() => {
        'location_list': locationList,
      };

  String queryParam() {
    final params = <String>[];
    if (locationList != null && locationList!.isNotEmpty) {
      params.add('city_ids=${locationList!.join(',')}');
    }
    final query = params.join('&');
    return '?$query';
  }
}
