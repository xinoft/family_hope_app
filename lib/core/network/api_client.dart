import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Thrown when the API's `CommonResponse` envelope reports `Success: false`.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// Shared Dio instance for talking to the InkersCore API, plus a helper
/// that understands the backend's one consistent response shape: every
/// endpoint returns a `CommonResponse` (`Success`/`ErrorMessage`/`Result`)
/// - see `InkersCore.Models.ResponseModels.CommonResponse` - serialized as
/// a bare JSON string with a `text/plain` content type (an existing
/// backend quirk, not a bug on this side), so responses need decoding
/// regardless of what content-type they arrive with.
class ApiClient {
  final Dio dio;

  /// Set by the session layer on login/logout. Kept here (rather than
  /// reaching into session state from this layer) so `core/` never depends
  /// on `features/`.
  String? authToken;

  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.current.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            )) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (authToken != null) {
                options.headers['Authorization'] = 'Bearer $authToken';
              }
              handler.next(options);
            },
          ),
        );
  }

  /// GETs [path] and returns the unwrapped `Result` payload of the
  /// `CommonResponse` envelope. Throws [ApiException] when the backend
  /// reports `Success: false`.
  Future<dynamic> getResult(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await dio.get(path, queryParameters: queryParameters);
    final envelope = _decodeJsonMap(response.data);
    if (envelope['Success'] != true) {
      throw ApiException(envelope['ErrorMessage'] as String? ?? 'Request to $path failed');
    }
    return envelope['Result'];
  }

  Map<String, dynamic> _decodeJsonMap(dynamic data) {
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
