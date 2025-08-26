import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/geo_location.dart';
import 'package:submee/models/user.dart';
import 'package:submee/providers/environment_service.dart';
import 'package:submee/utils/enum.dart';

import '../models/sublet.dart';
import '../models/sublet_filters.dart';
import '../network/dio_client.dart';
import '../utils/functions.dart';

final userService = Provider<UserService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = UserService(
    baseUrl: envService.environment.baseApiUrl,
    dioClient: client,
  );
  return service;
});

class UserService {
  UserService({
    required this.baseUrl,
    required this.dioClient,
  });
  final DioClient dioClient;
  final String baseUrl;

  Future<User> getUser() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/user/me',
        requireAuth: true,
      );
      return User.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSwipeInfoChat> getUserSwipe(int swipeId) async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/user/swipe/$swipeId',
        requireAuth: true,
      );
      if (response.data!['success'] != true) {
        throw Exception('Swipe not found');
      }
      return UserSwipeInfoChat.fromJson(response.data!['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<SubletNotifierState> getUserSubletters(SubletFilters filters) async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/user/subletters' + filters.queryParam(),
        requireAuth: true,
      );
      final results = response.data!['results'];
      final code = response.data!['code'] == null
          ? null
          : EmptySublet.values.firstWhere((e) => e.name == response.data!['code']);
      final subletList = (results as List).map((e) => Sublet.fromJson(e)).toList();
      return SubletNotifierState(
        sublets: subletList,
        code: code,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserRequested>> getUsersForNotifications(
    RequestStatus? status,
  ) async {
    try {
      final query = status != null ? '?status=${status.name}' : '';
      final response = await dioClient.get<Map<String, dynamic>>(
        '/user/swipes$query',
        requireAuth: true,
      );
      final results = response.data!['results'];
      return (results as List).map((e) => UserRequested.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeSublet(int id) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/user/$id/like',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikeSublet(int id) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/user/$id/unlike',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> declineUserRequest(int userId, int propertyId) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/user/$userId/reject/$propertyId',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserRequested> approveUserRequest(int userId, int propertyId) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        '/user/$userId/approve/$propertyId',
        requireAuth: true,
      );
      final result = UserRequested.fromJson(response.data!['result']);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? gender,
    GeoLocation? location,
    String? instagram,
    String? facebook,
  }) async {
    try {
      await dioClient.put<Map<String, dynamic>>(
        '/user',
        requireAuth: true,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'gender': gender,
          'latitude': location?.latitude,
          'longitude': location?.longitude,
          'instagram': instagram,
          'facebook': facebook,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/user/language',
        requireAuth: true,
        data: {
          'language': languageCode,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserPhotos(
    List<File?>? images,
  ) async {
    try {
      if (images == null || images.isEmpty || images.where((e) => e != null).isEmpty) return;

      final formData = FormData();

      // Add display order information for each photo
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        if (file == null) continue;
        final filename = file.path.split('/').last;

        // Use a unique field name for each photo's metadata
        formData.fields.add(MapEntry('displayOrder_$i', (i + 1).toString()));

        // Add the file with a field name that includes the index
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: filename,
              contentType: DioMediaType('image', getImageType(filename)),
            ),
          ),
        );
      }

      await dioClient.put<Map<String, dynamic>>(
        '/user/photos',
        requireAuth: true,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> getUserSubletDetail(int id) async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/user/sublet/$id',
        requireAuth: true,
      );
      return UserProfile.fromJson(response.data!['result']);
    } catch (e) {
      rethrow;
    }
  }
}
