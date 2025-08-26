import 'dart:io';

import 'package:intl/intl.dart';
import 'package:submee/models/property_details.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import 'enum.dart';

String getAcronimFromLocale(String locale) {
  switch (locale) {
    case 'en':
      return 'us';
    case 'he':
      return 'il';
    case 'es':
      return 'es';
    default:
      return 'us';
  }
}

String getNameFromLocale(String locale) {
  switch (locale) {
    case 'en':
      return 'English';
    case 'he':
      return 'Hebrew';
    case 'es':
      return 'Español';
    default:
      return 'English';
  }
}

String formatDateRange(DateTime startTime, DateTime endTime) {
  return '${DateFormat('E, MMM d').format(startTime)} - ${DateFormat('E, MMM d').format(endTime)}';
}

String formatDatePreview(DateTime startTime, DateTime endTime) {
  return '${DateFormat('dd.MM.yyyy').format(startTime)} - ${DateFormat('dd.MM.yyyy').format(endTime)}';
}

Future<void> launchMap(PropertyLocation location) async {
  String url;

  if (Platform.isIOS) {
    // Use Apple Maps for iOS
    if (location.coordinates != null) {
      // Navigate with coordinates
      url =
          'https://maps.apple.com/?q=${location.coordinates!.latitude},${location.coordinates!.longitude}';
    } else {
      // Navigate with address
      final encodedAddress = Uri.encodeComponent(location.address);
      url = 'https://maps.apple.com/?address=$encodedAddress';
    }
  } else {
    // Use Google Maps for Android and other platforms
    if (location.coordinates != null) {
      // Navigate with coordinates
      url =
          'https://www.google.com/maps/search/?api=1&query=${location.coordinates!.latitude},${location.coordinates!.longitude}';
    } else {
      // Navigate with address
      final encodedAddress = Uri.encodeComponent(location.address);
      url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    }
  }

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Handle case where map app cannot be launched
    throw 'Could not launch map application';
  }
}

String formatDateString(String timestamp) {
  // Parse the ISO string to DateTime
  final DateTime dateTime = DateTime.parse(timestamp);

  // Get month, day and year
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String day = dateTime.day.toString().padLeft(2, '0');
  final String year = dateTime.year.toString();

  // Return formatted date
  return '$month-$day-$year';
}

String getDatabaseItemNameTranslation(String? value, S locale) {
  if (value == null) {
    return '';
  }
  switch (value.toLowerCase()) {
    // Amenities
    case 'wifi':
      return locale.amenity_wifi;
    case 'tv':
      return locale.amenity_tv;
    case 'dish washer':
      return locale.amenity_dish_washer;
    case 'heater':
      return locale.amenity_heater;
    case 'elevator':
      return locale.amenity_elevator;
    case 'balcony':
      return locale.amenity_balcony;
    case 'shelter':
      return locale.amenity_shelter;
    case 'washer':
      return locale.amenity_washer;
    case 'kitchen':
      return locale.amenity_kitchen;
    case 'free parking':
      return locale.amenity_free_parking;
    case 'paid parking':
      return locale.amenity_paid_parking;

    // Property Types
    case 'house':
      return locale.property_house;
    case 'room':
      return locale.property_room;
    case 'flat villa':
      return locale.property_flat_villa;
    case 'basement':
      return locale.property_basement;
    case 'apartment':
      return locale.property_apartment;
    case 'penthouse':
      return locale.property_penthouse;
    case 'studio':
      return locale.property_studio;

    // Style attributes
    case 'unique':
      return locale.style_unique;
    case 'peaceful':
      return locale.style_peaceful;
    case 'stylish':
      return locale.style_stylish;

    // Page names
    case 'change-language':
      return locale.page_change_language;
    case 'edit-profile':
      return locale.page_edit_profile;
    case 'complete-profile':
      return locale.page_complete_profile;
    case 'notification':
    case 'host-notification':
      return locale.page_notification;
    case 'manage-property':
      return locale.page_host_sublet;
    case 'publish-page':
      return locale.page_publish_page;
    case 'forgot-password':
      return locale.page_forgot_password;
    case 'verify-otp':
      return locale.page_verify_otp;
    case 'reset-password':
      return locale.page_reset_password;
    case 'account':
      return locale.page_account;
    case 'chat':
      return locale.page_chat;
    case 'message':
      return locale.page_message;
    case 'new_message':
      return locale.page_message;
    case 'favorite':
    case 'host-favorite':
      return locale.favorite_page;

    // Error codes
    case 'email_login_failed_use_social_login':
      return locale.email_login_failed_use_social_login;
    case 'user_not_found':
      return locale.user_not_found;
    case 'invalid_code':
      return locale.invalid_code;
    case 'email_already_exist':
      return locale.email_already_exist;
    default:
      return value;
  }
}

List<Map<String, String>> getOnboardingData(S locale) {
  return [
    {
      'title': locale.onboarding_title_1,
      'description': locale.onboarding_description_1,
      'image': 'assets/images/onoarding_image_1.png',
    },
    {
      'title': locale.onboarding_title_2,
      'description': locale.onboarding_description_2,
      'image': 'assets/images/onoarding_image_2.png',
    },
  ];
}

String getImageType(String filename) {
  final extension = filename.toLowerCase().split('.').last;
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
      return 'png';
    case 'gif':
      return 'gif';
    case 'webp':
      return 'webp';
    case 'heic':
      return 'heic';
    default:
      return 'jpeg'; // Default to jpeg
  }
}

String getEmptyUsersTranslation(EmptySublet? code, S locale) {
  switch (code) {
    case EmptySublet.allUsersSwiped:
      return locale.empty_tenants_already_viewed + ' ' + locale.new_tenants_soon;
    case EmptySublet.noNearbyUsers:
      return locale.empty_tenants + ' ' + locale.new_tenants_soon;
    default:
      return locale.empty_tenants;
  }
}

int _calculateAge(String dob) {
  final DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dob);
  final DateTime today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

String getAgeFromDob(String dob) {
  final age = _calculateAge(dob);
  return '$age';
}
