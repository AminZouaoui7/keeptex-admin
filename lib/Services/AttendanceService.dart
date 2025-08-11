import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
  import 'package:keeptex/Core/utils/cacheHelper.dart';
  import '../Core/Models/employee_attendance.dart';


  class AttendanceService {
    late final Dio dio;
    static const String baseUrl = 'http://localhost:5000'; // Ensure your backend is running on this URL

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
  Future<void> markAbsent(String userId, DateTime date) async {
    await markAttendance(userId, date, 'Absent');
  }

  /// ✅ Marquer un employé comme présent
  Future<void> markPresent(String userId, DateTime date) async {
    await markAttendance(userId, date, 'Présent');
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


    /// 📊 Récupérer les statistiques de présence pour un utilisateur
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
        'conge': data['conge'] ?? 0,
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



    /// 📅 Créer ou mettre à jour une présence
  /// Map frontend French status to backend lowercase status
  String mapFrontendToBackendStatus(String status) {
    // Normalize status string: lowercase and replace 'é' with 'e'
    String normalizedStatus = status.toLowerCase().replaceAll('é', 'e');
    
    switch (normalizedStatus) {
      case 'present':
        return 'present';
      case 'absent':
        return 'absent';
      case 'conge':
        return 'conge';
      case 'non defini':
        return 'non_defini';
      default:
        return normalizedStatus;
    }
  }

  /// Map backend status to frontend French status
  String mapBackendToFrontendStatus(String status) {
    final x = (status ?? '').toLowerCase();
    if (x == 'present') return 'Présent';
    if (x == 'absent') return 'Absent';
    if (x == 'conge') return 'Congé';
    if (x == 'non_defini' || x == 'non défini') return 'Non défini';
    return 'Non défini';
  }

  Future<void> markAttendance(String userId, DateTime date, String status) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0];
      final token = await CacheHelper().getData(key: 'token');

      String backendStatus = mapFrontendToBackendStatus(status);

      final response = await dio.post(
        '/api/attendance',
        data: {
          'userId': userId,
          'date': formattedDate,
          'status': backendStatus,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de la mise à jour de la présence: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('contrainte unique') || e.toString().contains('unique constraint')) {
        throw Exception('Erreur de configuration de la base de données. Contactez l\'administrateur.');
      }
      throw Exception('Erreur lors de la mise à jour de la présence: $e');
    }
  }

  /// Get roster for a specific date
  Future<List<Map<String, dynamic>>> getRoster(DateTime day) async {
    try {
      final formattedDate = day.toIso8601String().split('T')[0];
      final token = await CacheHelper().getData(key: 'token');

      // Try to get roster from new endpoint
      try {
        final response = await dio.get(
          '/api/attendance/roster',
          queryParameters: {'date': formattedDate},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        final data = response.data;
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      } catch (e) {
        print('⚠️ Roster endpoint not available, falling back to getAttendanceByDate');
      }

      // Fallback to getAttendanceByDate
      final attendanceList = await getAttendanceByDate(day);
      return attendanceList.map((attendance) => {
        'userId': attendance.employeeId,
        'name': attendance.employeeName,
        'email': attendance.employeeName, // Use name as fallback for email
        'status': mapBackendToFrontendStatus(attendance.status),
        'checkIn': null,
        'checkOut': null,
        'notes': null,
      }).toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération du roster: $e');
      return [];
    }
  }

  /// Get monthly attendance stats for all users
  Future<Map<String, Map<String, int>>> getMonthlyStatsMap(String yyyymm) async {
    try {
      debugPrint('📊 Fetching attendance stats for month: $yyyymm');
      final token = await CacheHelper().getData(key: 'token');

      final response = await dio.get(
        '/api/attendance/stats',
        queryParameters: {'month': yyyymm},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 8));

      final data = response.data;
      debugPrint('📊 Attendance stats response: ${response.statusCode}, items: ${data is Map ? data['data']?.length ?? 0 : 0}');
      
      final Map<String, Map<String, int>> result = {};
      
      // Handle different response formats
      List<dynamic> statsList = [];
      if (data is Map && data.containsKey('data') && data['data'] is List) {
        statsList = data['data'] as List;
      } else if (data is List) {
        statsList = data;
      }

      for (final item in statsList) {
        if (item is Map<String, dynamic>) {
          final userId = item['userId']?.toString() ?? item['user_id']?.toString() ?? '';
          if (userId.isNotEmpty) {
            result[userId] = {
              'present': item['present'] ?? 0,
              'absent': item['absent'] ?? 0,
              'conge': item['conge'] ?? 0,
            };
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error fetching attendance stats: $e');
      return {}; // Return empty map on error
    }
  }

  /// Save bulk attendance records
  Future<void> saveBulk(DateTime day, List<Map<String, dynamic>> records) async {
    try {
      final formattedDate = day.toIso8601String().split('T')[0];
      final token = await CacheHelper().getData(key: 'token');

      // Map frontend status to backend status
      final backendRecords = records.map((record) => {
        'userId': record['userId'],
        'status': mapFrontendToBackendStatus(record['status']),
        'checkIn': record['checkIn'],
        'checkOut': record['checkOut'],
        'notes': record['notes'],
      }).toList();

      // Try bulk endpoint first
      try {
        final response = await dio.post(
          '/api/attendance/bulk',
          data: {
            'date': formattedDate,
            'records': backendRecords,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Bulk save successful');
          return;
        }
      } catch (e) {
        print('⚠️ Bulk endpoint not available, falling back to individual saves');
      }

      // Fallback to individual saves
      for (final record in backendRecords) {
        await markAttendance(
          record['userId'],
          day,
          mapBackendToFrontendStatus(record['status']),
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement en masse: $e');
    }
  }

    Future<List<EmployeeAttendance>> getAttendanceByDate(DateTime date) async {
      try {
        final formattedDate = date.toIso8601String().split('T')[0];
        final token = await CacheHelper().getData(key: 'token');

        final response = await dio.get(
          '/api/attendance',
          queryParameters: {
            'date': formattedDate,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        final data = response.data;
        List<EmployeeAttendance> attendances = [];

        List<dynamic> attendanceData = [];
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          attendanceData = data['data'] as List;
        } else if (data is List) {
          attendanceData = data;
        } else {
          print('DEBUG: Unexpected response format for getAttendanceByDate: $data');
          return [];
        }

        // Normalize and map each attendance record
        attendances = attendanceData.map((json) {
          final item = json as Map<String, dynamic>;

          // Handle nested employee object or direct fields
          Map<String, dynamic> employeeData = {};
          if (item.containsKey('employee') && item['employee'] != null) {
            employeeData = item['employee'] as Map<String, dynamic>;
          }

          // Normalize field names as specified in requirements
          final employeeId = item['employeeId'] ??
                           item['userId'] ??
                           item['user_id'] ??
                           item['employee_id'] ??
                           employeeData['id'] ??
                           '';

          final employeeName = item['employeeName'] ??
                            item['name'] ??
                            employeeData['name'] ??
                            employeeData['first_name'] != null && employeeData['last_name'] != null
                                ? '${employeeData['first_name']} ${employeeData['last_name']}'
                                : employeeData['email'] ??
                                  'Inconnu';

          final email = item['email'] ??
                       employeeData['email'] ??
                       '';

          final dateStr = item['date'] ?? '';
          final statusBackend = (item['status'] ?? 'non_defini').toString().toLowerCase();
          final statusFrontend = mapBackendToFrontendStatus(statusBackend);

          return EmployeeAttendance(
            employeeId: employeeId.toString(),
            employeeName: employeeName,
            date: DateTime.parse(dateStr),
            status: statusFrontend,
          );
        }).toList();

        return attendances;

      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError) {
          throw Exception('❌ Connexion impossible à $baseUrl — Vérifie que le backend est actif.');
        }
        print('❌ Erreur lors de la récupération des présences par date: ${e.response?.data ?? e.message}');
        return [];
      } catch (e) {
        print('❌ Erreur inattendue lors de la récupération des présences par date: $e');
        return [];
      }
    }
  }
