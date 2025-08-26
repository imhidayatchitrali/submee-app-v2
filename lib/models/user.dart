import 'package:submee/utils/enum.dart';

class User {
  User({
    required this.id,
    required this.email,
    required this.onboardingStep,
    required this.language,
    required this.profileProgress,
    required this.isHost,
    this.firstName,
    this.gender,
    this.lastName,
    this.dateOfBirth,
    this.photoUrl,
    this.city,
    this.country,
    this.photos,
    this.instagramUsername,
    this.facebookUsername,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      onboardingStep: getCurrentStep(json['onboarding_step']),
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      language: json['language'],
      dateOfBirth: json['date_of_birth'],
      isHost: json['is_host'] as bool? ?? false,
      photoUrl: json['photo_url'],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((e) => UserPhoto.fromJson(e)).toList()
          : null,
      city: json['address']?['city'],
      country: json['address']?['country'],
      instagramUsername: json['instagram_username'],
      facebookUsername: json['facebook_username'],
      profileProgress: json['profile_progress'] as int? ?? 0,
    );
  }
  final int id;
  final String email;
  final OnboardingStep onboardingStep;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? instagramUsername;
  final String? facebookUsername;
  final String language;
  final String? dateOfBirth;
  final String? photoUrl;
  final List<UserPhoto>? photos;
  final String? city;
  final String? country;
  final int profileProgress;
  final bool isHost;

  String? get userLocation {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return null;
  }

  static OnboardingStep getCurrentStep(String value) {
    if (value.toLowerCase() == 'completed') {
      return OnboardingStep.completed;
    }
    final values = value.split('_');
    final valueConverted =
        values[0] + values[1].substring(0, 1).toUpperCase() + values[1].substring(1);
    return OnboardingStep.values.firstWhere(
      (e) => e.name == valueConverted,
    );
  }
}

class UserRequested {
  UserRequested({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photos,
    required this.bio,
    required this.location,
    required this.createdAt,
    required this.status,
    required this.propertyId,
    required this.propertyTitle,
    required this.conversationId,
  });

  factory UserRequested.fromJson(Map<String, dynamic> json) {
    return UserRequested(
      id: json['id'] as int, // property_swipes id
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList() ?? [],
      bio: (json['bio'] ?? 'Here should be the bio of the user') as String,
      propertyTitle: json['property']['title'] as String,
      propertyId: json['property']['id'] as int,
      location: json['location'] as String,
      conversationId: json['conversation_id'] as int?,
      createdAt: json['created_at'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending').toString().toLowerCase(),
      ),
    );
  }
  final int id;
  final String firstName;
  final String lastName;
  final List<String> photos;
  final String bio;
  final String location;
  final String createdAt;
  final RequestStatus status;
  final int propertyId;
  final int? conversationId;
  final String propertyTitle;
}

class UserPhoto {
  UserPhoto({
    required this.id,
    required this.url,
    required this.order,
    required this.isProfile,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      id: json['id'] as int,
      url: json['url'] as String,
      order: json['display_order'] as int,
      isProfile: json['is_profile'] as bool,
    );
  }
  final int id;
  final String url;
  final int order;
  final bool isProfile;
}

class UserSwipeInfoChat {
  UserSwipeInfoChat({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photo,
    required this.propertyTitle,
  });

  factory UserSwipeInfoChat.fromJson(Map<String, dynamic> json) {
    return UserSwipeInfoChat(
      id: json['other_user_id'] as int, // property_swipes id
      firstName: json['other_user_first_name'] as String,
      lastName: json['other_user_last_name'] as String,
      photo: json['other_user_photo'] as String,
      propertyTitle: json['property_title'] as String,
    );
  }
  final int id;
  final String firstName;
  final String lastName;
  final String photo;
  final String propertyTitle;
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photos,
    required this.bio,
    required this.dob,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int, // property_swipes id
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList() ?? [],
      bio: json['bio'] as String?,
      dob: json['date_of_birth'] as String,
    );
  }
  final int id;
  final String firstName;
  final String lastName;
  final List<String> photos;
  final String? bio;
  final String dob;
}
