import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/providers/environment_service.dart';

import '../helpers/image_helper.dart';
import '../models/property.dart';
import '../models/property_details.dart';
import '../models/property_filters.dart';
import '../network/dio_client.dart';
import '../utils/enum.dart';

final propertyService = Provider<PropertyService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = PropertyService(
    baseUrl: envService.environment.baseApiUrl,
    dioClient: client,
  );
  return service;
});

class PropertyService {
  PropertyService({
    required this.baseUrl,
    required this.dioClient,
  });
  final DioClient dioClient;
  final String baseUrl;

  Future<void> publishProperty(PropertyInput data) async {
    try {
      final List<String> base64Photos = [];
      if (data.photos.isNotEmpty) {
        if (data.photos.isNotEmpty) {
          for (final photo in data.photos) {
            final base64 = await imageToBase64(photo);
            base64Photos.add(base64);
          }
        }
      }
      await dioClient.post<Map<String, dynamic>>(
        '/property/publish',
        data: {
          ...data.toJson(),
          'photos': base64Photos,
        },
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProperty(int id, PropertyInput data) async {
    try {
      final List<String> base64Photos = [];
      if (data.photos.isNotEmpty) {
        if (data.photos.isNotEmpty) {
          for (final photo in data.photos) {
            final base64 = await imageToBase64(photo);
            base64Photos.add(base64);
          }
        }
      }
      await dioClient.put<Map<String, dynamic>>(
        '/property/$id',
        data: {
          ...data.toJson(),
          'photos': base64Photos,
        },
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PropertyResult> getProperties(PropertyFilters filters) async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/property' + filters.queryParam(),
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      return PropertyResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<PropertyDetails> getPropertyDetail(int id) async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/property/$id',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      final data = response.data!;
      return PropertyDetails.fromJson(data['result']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeProperty(int id) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/property/$id/like',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikeProperty(int id) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/property/$id/unlike',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawPropertyRequest(int id) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/property/$id/withdraw',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PropertyRequested>> getPropertiesForNotifications(
    RequestStatus? status,
  ) async {
    try {
      final query = status != null ? '?status=${status.name}' : '';
      final response = await dioClient.get<Map<String, dynamic>>(
        '/property/status$query',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      return response.data!['properties']
          .map<PropertyRequested>((e) => PropertyRequested.fromJson(e))
          .toList()
          .cast<PropertyRequested>();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PropertyDisplay>> getHostProperties() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/property/host',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      return (response.data!['properties'] ?? [])
          .map((e) => PropertyDisplay.fromJson(e))
          .toList()
          .cast<PropertyDisplay>();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProperty(int id) async {
    try {
      await dioClient.delete<Map<String, dynamic>>(
        '/property/$id',
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
