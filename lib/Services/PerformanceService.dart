import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:keeptex/Core/Models/employee_performance.dart';
import 'package:keeptex/Core/api/endpoints.dart';

import '../Core/utils/cacheHelper.dart';

class PerformanceService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.240.1:5000',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  Future<Options> _getAuthOptions() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<({String month, List rows, double total})>
      getMonthlyPerformance(String yyyymm) async {
    try {
      final authOptions = await _getAuthOptions();
      final token = (authOptions.headers?['Authorization'] as String?)?.substring(7) ?? '';
      debugPrint('[PERF] url=${_dio.options.baseUrl}/api/performance?month=$yyyymm token=${token.substring(0, 3)}...');
      
      final resp = await _dio.get(
        '/api/performance',
        queryParameters: {'month': yyyymm},
        options: authOptions,
      ).timeout(const Duration(seconds: 8));

      debugPrint('[PERF] status=${resp.statusCode} url=${resp.realUri}');

      final data = resp.data;
      final list = (data is Map && data['data'] is List) ? (data['data'] as List) : const [];
      final total = (data is Map && data['total_amount'] != null)
          ? (data['total_amount'] as num).toDouble() : 0.0;
      
      return (rows: List<Map<String, dynamic>>.from(list), total: total, month: yyyymm);
    } on TimeoutException catch (e) {
      debugPrint('[PERF] timeout');
      return (rows: [], total: 0.0, month: yyyymm);
    } on DioException catch (e) {
      debugPrint('[PERF] error: $e');
      return (rows: [], total: 0.0, month: yyyymm);
    } catch (e) {
      debugPrint('[PERF] error: $e');
      return (rows: [], total: 0.0, month: yyyymm);
    }
  }
}