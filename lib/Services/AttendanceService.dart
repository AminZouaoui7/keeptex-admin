import 'package:dio/dio.dart';
import '../Core/utils/cacheHelper.dart';
import '../Core/api/endpoints.dart';

class AttendanceService {
  late final Dio dio;

  AttendanceService() {
    dio = Dio(BaseOptions(
      baseUrl: EndPoint.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 15),
    ));

    // Ajouter des interceptors si nécessaire
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Marquer un employé comme présent
  Future<void> markPresent(String userId, DateTime date) async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      
      print('Marking present for user: $userId on date: $date');
      
      await dio.post(
        EndPoint.markPresent(userId),
        data: {
          'date': date.toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Successfully marked present');
    } catch (e) {
      print('Error marking present: $e');
      throw Exception('Erreur lors du marquage présent: $e');
    }
  }

  // Marquer un employé comme absent
  Future<void> markAbsent(String userId, DateTime date) async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      
      print('Marking absent for user: $userId on date: $date');
      
      await dio.post(
        EndPoint.markAbsent(userId),
        data: {
          'date': date.toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Successfully marked absent');
    } catch (e) {
      print('Error marking absent: $e');
      throw Exception('Erreur lors du marquage absent: $e');
    }
  }

  // Enregistrer un acompte
  Future<void> addAdvance(String userId, double amount) async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      
      print('Adding advance of $amount DH for user: $userId');
      
      await dio.post(
        EndPoint.addAdvance(userId),
        data: {
          'amount': amount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Successfully added advance');
    } catch (e) {
      print('Error adding advance: $e');
      throw Exception('Erreur lors de l\'ajout de l\'acompte: $e');
    }
  }

  // Obtenir l'historique de présence d'un employé
  Future<List<Map<String, dynamic>>> getAttendanceHistory(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await this.dio.get(
        EndPoint.getAttendanceHistory(userId),
        queryParameters: params,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Obtenir les statistiques de présence
  Future<Map<String, int>> getAttendanceStats(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await this.dio.get(
        EndPoint.getAttendanceStats(userId),
        queryParameters: params,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Successfully retrieved attendance stats');
      
      final data = response.data;
      if (data is Map) {
        return {
          'present': data['present'] ?? 0,
          'absent': data['absent'] ?? 0,
          'total': data['total'] ?? 0,
        };
      }
      return {'present': 0, 'absent': 0, 'total': 0};
    } catch (e) {
      print('Error getting attendance stats: $e');
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Méthode pour tester la connexion au backend
  Future<bool> testConnection() async {
    try {
      final token = await CacheHelper().getData(key: 'token');
      if (token == null) {
        print('No token found - user not logged in');
        return false;
      }
      
      final response = await this.dio.get(
        EndPoint.baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Backend connection successful');
      return true;
    } catch (e) {
      print('Backend connection failed: $e');
      return false;
    }
  }
}