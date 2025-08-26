import 'package:submee/utils/enum.dart';

class Sublet {
  const Sublet({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photos,
    required this.dob,
    required this.location,
    required this.distance,
  });
  factory Sublet.fromJson(Map<String, dynamic> json) {
    return Sublet(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      location: json['location'] as String,
      photos: (json['photos'] ?? []).toList().cast<String>(),
      dob: json['date_of_birth'] as String?,
      distance: (json['distance'] as num).toDouble(),
    );
  }

  final int id;
  final String firstName;
  final String lastName;
  final String location;
  final List<String> photos;
  final String? dob;
  final double distance;
}

class SubletNotifierState {
  SubletNotifierState({
    required this.sublets,
    this.code,
  });
  final List<Sublet> sublets;
  final EmptySublet? code;
}
