import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/providers/environment_service.dart';
import 'package:submee/utils/functions.dart';

import '../models/auth_response.dart';
import '../network/dio_client.dart';

final onboardingService = Provider<OnboardingService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = OnboardingService(
    baseUrl: envService.environment.baseApiUrl,
    client: client,
  );
  return service;
});

class OnboardingService {
  OnboardingService({
    required this.baseUrl,
    required this.client,
  });
  final DioClient client;
  final String baseUrl;

  Future<void> submitPersonalDetails({
    required String firstName,
    required String lastName,
    required String email,
    required String dateOfBirth,
    required String password,
  }) async {
    try {
      // Send token to your backend
      final response = await client.post<Map<String, dynamic>>(
        '/onboarding-public/personal-info',
        data: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'date_of_birth': dateOfBirth,
          'password': password,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }
      final authResponse = AuthResponse.fromJson(response.data!);
      client.setAuthToken(authResponse.token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to submitPersonalDetails: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendValidationCode(String dialCode, String phoneNumber) async {
    try {
      await client.post<Map<String, dynamic>>(
        '/onboarding/send-code',
        data: {
          'dialCode': dialCode,
          'phoneNumber': phoneNumber,
        },
        requireAuth: true,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to sendValidationCode: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sendValidationCode: $e');
    }
  }

  Future<void> verifyCode(
    String dialCode,
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      await client.post<Map<String, dynamic>>(
        '/onboarding/verify-code',
        data: {
          'code': otpCode,
          'dialCode': dialCode,
          'phoneNumber': phoneNumber,
        },
        requireAuth: true,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to verifyCode: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitUserPhotos(List<File> images) async {
    try {
      if (images.isEmpty) return;

      final formData = FormData();

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final filename = file.path.split('/').last;

        formData.files.add(
          MapEntry(
            'images', // Field name must be 'images' to match server's upload.array('images', 6)
            await MultipartFile.fromFile(
              file.path,
              filename: filename,
              contentType: DioMediaType('image', getImageType(filename)),
            ),
          ),
        );
      }

      await client.post<Map<String, dynamic>>(
        '/onboarding/upload-photo',
        data: formData,
        requireAuth: true,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to submitProfileImage: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to submitProfileImage: $e');
    }
  }

  Future<void> sendEmailValidationCode(String email) async {
    try {
      await client.post<Map<String, dynamic>>(
        '/onboarding-public/send-email-code',
        data: {
          'email': email.toLowerCase(),
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to sendEmailValidationCode: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sendEmailValidationCode: $e');
    }
  }

  Future<void> verifyEmailCode(
    String email,
    String otpCode,
  ) async {
    try {
      await client.post<Map<String, dynamic>>(
        '/onboarding-public/verify-email-code',
        data: {
          'code': otpCode,
          'email': email,
        },
        requireAuth: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to verifyEmailCode: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
