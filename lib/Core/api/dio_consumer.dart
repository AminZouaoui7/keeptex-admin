import 'package:dio/dio.dart';

import '../utils/cacheHelper.dart';
import 'api_consumer.dart';
import 'endpoints.dart';

class DioConsumer implements ApiConsumer {
  final Dio dio;

  DioConsumer({Dio? dio})
      : dio = dio ??
      Dio(BaseOptions(
        baseUrl: EndPoint.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      )) {
    print("📌 Dio instancié avec baseUrl : ${this.dio.options.baseUrl}");
  }

  Future<Options> _getAuthHeaders() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }

  String _cleanPath(String path) => path.startsWith("/") ? path.substring(1) : path;

  void _logSuccess(String method, Response response) {
    print("✅ $method ${response.requestOptions.uri} → ${response.statusCode}");
    print("📦 Données reçues : ${response.data}");
  }

  void _logError(String method, DioException e) {
    print("❌ $method DioException : ${e.message}");
    print("🔗 URL : ${e.requestOptions.uri}");
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final options = await _getAuthHeaders();
      final response = await dio.get(_cleanPath(path), queryParameters: queryParameters, options: options);
      _logSuccess("GET", response);
      return response.data;
    } on DioException catch (e) {
      _logError("GET", e);
      return {"status": false, "message": "Erreur réseau : ${e.message}"};
    }
  }

  @override
  Future<dynamic> post(String path,
      {Object? data, Options? options, Map<String, dynamic>? queryParameters}) async {
    try {
      options ??= await _getAuthHeaders();
      final response = await dio.post(_cleanPath(path), data: data, queryParameters: queryParameters, options: options);
      _logSuccess("POST", response);
      return response.data;
    } on DioException catch (e) {
      _logError("POST", e);
      return {"status": false, "message": "Erreur réseau : ${e.message}"};
    }
  }

  @override
  Future<dynamic> put(String path,
      {Object? data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      options ??= await _getAuthHeaders();
      final response = await dio.put(_cleanPath(path), data: data, queryParameters: queryParameters, options: options);
      _logSuccess("PUT", response);
      return response.data;
    } on DioException catch (e) {
      _logError("PUT", e);
      return {"status": false, "message": "Erreur réseau : ${e.message}"};
    }
  }

  @override
  Future<dynamic> patch(String path,
      {Object? data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      options ??= await _getAuthHeaders();
      final response =
      await dio.patch(_cleanPath(path), data: data, queryParameters: queryParameters, options: options);
      _logSuccess("PATCH", response);
      return response.data;
    } on DioException catch (e) {
      _logError("PATCH", e);
      return {"status": false, "message": "Erreur réseau : ${e.message}"};
    }
  }

  @override
  Future<dynamic> delete(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final options = await _getAuthHeaders();
      final response = await dio.delete(_cleanPath(path), data: data, queryParameters: queryParameters, options: options);
      _logSuccess("DELETE", response);
      return response.data;
    } on DioException catch (e) {
      _logError("DELETE", e);
      return {"status": false, "message": "Erreur réseau : ${e.message}"};
    }
  }
}

