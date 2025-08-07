import 'package:dio/dio.dart';
import '../Core/utils/cacheHelper.dart';

class AttendanceService {
  late final Dio dio;
  static const String baseUrl = 'http://192.168.1.128:5000/api';

  AttendanceService() {
    print('📡 AttendanceService initialized with baseUrl: $baseUrl');

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 15),
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  /// 🔐 Génère les headers avec token
  Future<Options> _getAuthOptions() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  /// ❌ Marquer un employé comme absent
  Future<Map<String, dynamic>> markAbsent(String userId, DateTime date) async {
    try {
      final response = await dio.put(
        '/users/$userId/mark-absent',
        data: {'date': date.toIso8601String().split('T')[0]},
        options: await _getAuthOptions(),
      );
      print("🧾 userId envoyé: $userId");
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('❌ Connexion impossible à $baseUrl — Vérifie que le backend est actif.');
      }
      throw Exception('❌ Erreur: ${e.response?.data ?? e.message}');
    }
  }

  /// ✅ Marquer un employé comme présent
  Future<Map<String, dynamic>> markPresent(String userId, DateTime date) async {
    try {
      final response = await dio.put(
        '/users/$userId/mark-present',
        data: {'date': date.toIso8601String().split('T')[0]},
        options: await _getAuthOptions(),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('❌ Connexion impossible à $baseUrl — Vérifie que le backend est actif.');
      }
      throw Exception('❌ Erreur: ${e.response?.data ?? e.message}');
    }
  }

  /// 💸 Ajouter un acompte
  Future<void> addAdvance(String userId, double amount) async {
    try {
      print('💸 Ajout de $amount DT pour l’utilisateur $userId');

      await dio.put(
        '/users/$userId/add-advance',
        data: {'amount': amount},
        options: await _getAuthOptions(),
      );

      print('✅ Acompte ajouté avec succès');
    } catch (e) {
      print('❌ Erreur acompte: $e');
      throw Exception('Erreur lors de l\'ajout de l\'acompte: $e');
    }
  }

  /// 📅 Récupérer l’historique de présence
  Future<List<Map<String, dynamic>>> getAttendanceHistory(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) params['endDate'] = endDate.toIso8601String().split('T')[0];

      final response = await dio.get(
        '/users/$userId/attendance',
        queryParameters: params,
        options: await _getAuthOptions(),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('❌ Erreur historique présence: $e');
      return [];
    }
  }

  /// 📊 Récupérer les statistiques de présence
  Future<Map<String, int>> getAttendanceStats(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) params['endDate'] = endDate.toIso8601String().split('T')[0];

      final response = await dio.get(
        '/users/$userId/attendance-stats',
        queryParameters: params,
        options: await _getAuthOptions(),
      );

      final data = response.data;
      return {
        'present': data['present'] ?? 0,
        'absent': data['absent'] ?? 0,
        'total': data['total'] ?? 0,
      };
    } catch (e) {
      print('❌ Erreur stats présence: $e');
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  /// 🌐 Tester la connexion au backend
  Future<bool> testConnection() async {
    try {
      final response = await dio.get(
        '/',
        options: await _getAuthOptions(),
      );
      print('✅ Connexion backend réussie');
      return true;
    } catch (e) {
      print('❌ Connexion backend échouée: $e');
      return false;
    }
  }
}
