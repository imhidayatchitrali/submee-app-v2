import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/app_version.dart';
import 'package:submee/models/property_publish.dart';
import 'package:submee/providers/environment_service.dart';

import '../models/filter.dart';
import '../models/location.dart';
import '../network/dio_client.dart';

final configService = Provider<ConfigService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = ConfigService(
    baseUrl: envService.environment.baseApiUrl,
    environment: envService.environment.environmentName,
    dioClient: client,
  );
  return service;
});

class ConfigService {
  ConfigService({
    required this.baseUrl,
    required this.environment,
    required this.dioClient,
  });
  final DioClient dioClient;
  final String baseUrl;
  final String environment;

  Future<PropertyData> getPropertyCreationData() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/config/property',
        requireAuth: true,
      );
      return PropertyData.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationItem>> getLocations() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/config/locations',
        requireAuth: true,
      );
      return ((response.data!['locations'] ?? []) as List)
          .map((e) => LocationItem.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Filter> getFilters() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/config/filters',
        requireAuth: true,
      );
      return Filter.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<AppVersion> getAppVersion() async {
    try {
      final response = await dioClient.get<Map<String, dynamic>>(
        '/version?environment=$environment&platform=${Platform.isAndroid ? 'android' : 'ios'}',
        requireAuth: false,
        useApiKey: true,
      );
      return AppVersion.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }
}
