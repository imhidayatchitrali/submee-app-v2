import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/utils/preferences.dart';

import '../providers/environment_service.dart';
import '../utils/api_exception.dart';
import '../utils/logger.dart';

final dioClient = Provider<DioClient>((ref) {
  final envService = ref.watch(environmentService);
  return DioClient(
    baseUrl: envService.environment.baseApiUrl,
    apiKey: envService.environment.apiKey,
  );
});

class DioClient {
  DioClient({
    required this.baseUrl,
    required this.apiKey,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    _setupInterceptors();
  }
  late final Dio _dio;
  final String baseUrl;
  final String apiKey;
  String? _authToken;

  void _setupInterceptors() {
    // Cache options
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [],
      maxStale: const Duration(days: 1),
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    );

    // Add interceptors
    _dio.interceptors.addAll([
      DioCacheInterceptor(options: cacheOptions),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) {
          // Convert the Dio log object to a string
          final String logString = object.toString();

          // Determine log level based on content
          if (logString.contains('ERROR') || logString.contains('Exception')) {
            Logger.e('Dio: $logString');
          } else if (logString.contains('[DIO] HTTP REQUEST')) {
            // Logger.d('Dio Request: $logString');
          } else if (logString.contains('[DIO] HTTP RESPONSE')) {
            // Logger.d('Dio Response: $logString');
          } else {
            // Logger.d('Dio: $logString');
          }
        },
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
      ),
    ]);
  }

  // Set authentication token
  void setAuthToken(String token) {
    Preferences.saveToken(token);
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    Preferences.removeToken();
    _authToken = null;
  }

  // GET request with caching
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CachePolicy? cachePolicy,
    bool requireAuth = false,
    bool useApiKey = false,
  }) async {
    try {
      if (requireAuth && _authToken == null) {
        throw UnauthorizedException('Authentication required', 'unauthorized');
      }

      if (useApiKey) {
        _dio.options.headers['x-api-key'] = apiKey;
      }

      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: cachePolicy != null
            ? CacheOptions(policy: cachePolicy, store: null).toOptions()
            : null,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
  }) async {
    try {
      if (requireAuth && _authToken == null) {
        throw UnauthorizedException('Authentication required', 'unauthorized');
      }

      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
  }) async {
    try {
      if (requireAuth && _authToken == null) {
        throw UnauthorizedException('Authentication required', 'unauthorized');
      }

      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = false,
  }) async {
    try {
      if (requireAuth && _authToken == null) {
        throw UnauthorizedException('Authentication required', 'unauthorized');
      }

      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling (unchanged)
  Exception _handleError(DioException error) {
    final Exception exception;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException('Connection timeout', 'connection_timeout');
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final code = data?['code'];

        switch (statusCode) {
          case 400:
            exception =
                BadRequestException(data?['message'] ?? 'Bad request', code ?? 'bad_request');
            break;
          case 401:
            exception =
                UnauthorizedException(data?['message'] ?? 'Unauthorized', code ?? 'unauthorized');
            break;
          case 403:
            exception = ForbiddenException(data?['message'] ?? 'Forbidden', code ?? 'forbidden');
            break;
          case 404:
            exception = NotFoundException(data?['message'] ?? 'Not found', code ?? 'not_found');
            break;
          case 500:
            exception =
                ServerException(data?['message'] ?? 'Server error', code ?? 'server_error');
            break;
          default:
            exception = ApiException(
              data?['message'] ?? 'Unknown error',
              code ?? 'unknown_code',
              statusCode ?? 0,
            );
            break;
        }
        break;

      case DioExceptionType.cancel:
        exception = RequestCancelledException('Request cancelled', 'request_cancelled');
        break;

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          exception = NoInternetException('No internet connection', 'no_internet');
        } else {
          exception = UnknownException(error.message ?? 'Unknown error', 'unknown');
        }
        break;

      default:
        exception = ApiException(error.message ?? 'Unknown error', 'unknown', 0);
        break;
    }

    // Log the error using your custom logger
    final String errorMessage = 'API Error: ${exception.toString()}';
    final String requestDetails =
        'URL: ${error.requestOptions.uri}, Method: ${error.requestOptions.method}';

    // Log as error to ensure it gets sent to Firebase Crashlytics in production
    Logger.e(
      '$errorMessage\n$requestDetails',
      e: exception,
      s: error.stackTrace,
    );

    return exception;
  }
}
