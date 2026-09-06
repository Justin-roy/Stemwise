import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// Thin Dio wrapper (spec §91): attaches the access token, unwraps the STEMWISE
/// response envelope, maps errors to [ApiException], and transparently refreshes
/// the access token once on 401 before retrying.
class ApiClient {
  ApiClient(this._storage, {Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)) {
    _dio.options
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers['Content-Type'] = 'application/json';
    // A bare client used only for token refresh (no interceptors → no recursion).
    _refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  }

  final Dio _dio;
  late final Dio _refreshDio;
  final SecureStorage _storage;

  /// Called when refresh fails so the app can log the user out (spec §47, §91).
  void Function()? onAuthFailure;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _authed().get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _request(() => _authed().post(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _request(() => _authed().patch(path, data: body));

  Future<dynamic> delete(String path) =>
      _request(() => _authed().delete(path));

  Dio _authed() => _dio;

  Future<dynamic> _request(Future<Response> Function() send) async {
    try {
      final token = await _storage.accessToken;
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      } else {
        _dio.options.headers.remove('Authorization');
      }
      final res = await send();
      return _unwrap(res);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && await _tryRefresh()) {
        try {
          final res = await send();
          return _unwrap(res);
        } on DioException catch (e2) {
          throw _toApiException(e2);
        }
      }
      final ex = _toApiException(e);
      if (ex.isUnauthorized) onAuthFailure?.call();
      throw ex;
    }
  }

  dynamic _unwrap(Response res) {
    final data = res.data;
    if (data is Map && data['success'] == true) {
      if (data.containsKey('meta')) {
        return {'data': data['data'], 'meta': data['meta']};
      }
      return data['data'];
    }
    return data;
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.refreshToken;
    if (refresh == null) return false;
    try {
      final res = await _refreshDio.post('/auth/refresh',
          data: {'refreshToken': refresh});
      final data = res.data['data'] as Map;
      await _storage.saveTokens(
          data['accessToken'] as String, data['refreshToken'] as String);
      return true;
    } catch (_) {
      await _storage.clear();
      onAuthFailure?.call();
      return false;
    }
  }

  ApiException _toApiException(DioException e) {
    final res = e.response;
    if (res == null) {
      return ApiException(
        "You're offline. Your current calculation can still be used, but saved data requires a connection.",
      );
    }
    final body = res.data;
    String message = 'Something went wrong.';
    String? code;
    List<String> fieldErrors = const [];
    if (body is Map) {
      message = (body['message'] as String?) ?? message;
      code = body['code'] as String?;
      final errs = body['errors'];
      if (errs is List) fieldErrors = errs.map((e) => e.toString()).toList();
    }
    return ApiException(message,
        statusCode: res.statusCode, code: code, fieldErrors: fieldErrors);
  }
}
