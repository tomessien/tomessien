import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thesis_rosca_app/providers/auth_provider.dart';

class ApiClient {
  final Dio _dio;
  final AuthProvider _authProvider;

  ApiClient(this._authProvider) : _dio = Dio() {
    _dio.options.baseUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000'); // Base URL for your NestJS backend
    _dio.options.connectTimeout = const Duration(seconds: 5); // 5 seconds
    _dio.options.receiveTimeout = const Duration(seconds: 3); // 3 seconds

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authProvider.isAuthenticated && _authProvider.token != null) {
          options.headers['Authorization'] = 'Bearer ${_authProvider.token}';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized errors, e.g., log out user
          _authProvider.logout();
        }
        return handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  Dio get dio => _dio;
}

