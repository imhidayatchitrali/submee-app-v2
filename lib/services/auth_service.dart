import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:submee/providers/environment_service.dart';

import '../models/auth_response.dart';
import '../network/dio_client.dart';
import '../utils/api_exception.dart';
import '../utils/logger.dart';

final authService = Provider<AuthService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final googleSignIn = GoogleSignIn(
    serverClientId: envService.environment.googleClientIdSignIn,
    scopes: [
      'openid',
      'email',
      'profile',
    ],
  );
  final service = AuthService(
    baseUrl: envService.environment.baseApiUrl,
    googleSignIn: googleSignIn,
    dioClient: client,
  );
  return service;
});

class AuthService {
  AuthService({
    required this.googleSignIn,
    required this.baseUrl,
    required this.dioClient,
  });
  final DioClient dioClient;
  final GoogleSignIn googleSignIn;
  final String baseUrl;

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Start Google Sign In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign In was cancelled');

      // Get Google auth tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('Failed to get ID token');

      // Send token to your backend
      final response = await dioClient.post<Map<String, dynamic>>(
        '/auth/google',
        data: {
          'idToken': idToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      // Parse response
      final authResponse = AuthResponse.fromJson(response.data!);
      dioClient.setAuthToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to sign in with Google: ${e.message}');
      }
    } catch (e) {
      await signOut();
      Logger.e('Failed to sign in with Google: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final token = credential.identityToken;
      if (token == null) throw Exception('Failed to get ID token');

      // Send token to your backend
      final response = await dioClient.post<Map<String, dynamic>>(
        '/auth/apple',
        data: {
          'code': credential.authorizationCode,
          'familyName': credential.familyName,
          'givenName': credential.givenName,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      // Parse response
      final authResponse = AuthResponse.fromJson(response.data!);
      dioClient.setAuthToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to sign in with Apple: ${e.message}');
      }
    } catch (e) {
      await signOut();
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  Future<AuthResponse> signinWithEmail(String email, String password) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data!);
      dioClient.setAuthToken(authResponse.token);
      return authResponse;
    } on ApiException catch (e) {
      Logger.e('Failed to sign in with email: ${e.message}');
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on ApiException catch (e) {
      Logger.e('Failed to send password reset email: ${e.message}');
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String password,
    required String token,
  }) async {
    try {
      await dioClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {
          'password': password,
          'token': token,
        },
      );
    } on ApiException catch (e) {
      Logger.e('Failed to send password reset email: ${e.message}');
      rethrow;
    }
  }

  Future<String> verifyCodeOnResetPassword({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        '/auth/verify-code',
        data: {
          'code': code,
          'email': email,
        },
      );
      Logger.d('Verify code response: $response');
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      return response.data!['token'] as String;
    } on ApiException catch (e) {
      Logger.e('Failed to send password reset email: ${e.message}');
      rethrow;
    }
  }

  void saveAuthToken(String token) {
    dioClient.setAuthToken(token);
  }

  Future<void> signOut() async {
    dioClient.post<Map<String, dynamic>>(
      '/auth/signout',
      requireAuth: true,
    );
    await googleSignIn.signOut();
    dioClient.clearAuthToken();
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
