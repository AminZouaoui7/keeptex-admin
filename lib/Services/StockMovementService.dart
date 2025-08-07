import 'package:dio/dio.dart';
import 'package:keeptex/pages/stock/StockMovementsPage.dart';
import '../Core/utils/cacheHelper.dart';

class StockMovementService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.128:5000/api',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  // Mode mock pour tests locaux
  bool _useMock = false;
  final List<StockMovement> _mockMovements = [
    StockMovement(
      id: '1',
      articleName: 'Article Test 1',
      type: 'ENTREE',
      quantity: 10,
      oldQuantity: 0,
      newQuantity: 10,
      date: DateTime.now().subtract(Duration(days: 1)),
      user: 'Admin',
      reason: 'Création d\'article',
    ),
    StockMovement(
      id: '2',
      articleName: 'Article Test 2',
      type: 'SORTIE',
      quantity: -5,
      oldQuantity: 20,
      newQuantity: 15,
      date: DateTime.now().subtract(Duration(hours: 2)),
      user: 'Admin',
      reason: 'Vente',
    ),
    StockMovement(
      id: '3',
      articleName: 'Produit A',
      type: 'ENTREE',
      quantity: 25,
      oldQuantity: 10,
      newQuantity: 35,
      date: DateTime.now().subtract(Duration(days: 3)),
      user: 'System',
      reason: 'Réapprovisionnement',
    ),
  ];

  Future<Options> _getHeaders() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // GET /api/stock-movements - Obtenir tous les mouvements avec paramètres de filtrage
  Future<List<StockMovement>> getStockMovements({
    int page = 1,
    int limit = 50,
    String? articleId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMock) {
      print('Mode MOCK activé - retour des données de test');
      return _mockMovements;
    }

    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (articleId != null) params['articleId'] = articleId;
      if (type != null) params['type'] = type;
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/stock-movements',
        queryParameters: params,
        options: await _getHeaders(),
      );
      
      final raw = response.data;
      final List<dynamic> data = raw is List ? raw : (raw['data'] ?? []);
      
      return data.map((json) => StockMovement.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Endpoint /api/stock-movements non trouvé - activation mode MOCK');
        return _mockMovements;
      }
      print('Erreur getStockMovements: ${e.message}');
      rethrow;
    }
  }

  // GET /api/stock-movements/article/:id - Historique d'un article spécifique
  Future<List<StockMovement>> getArticleMovements(String articleId, {int page = 1, int limit = 50}) async {
    return getStockMovements(
      articleId: articleId,
      page: page,
      limit: limit,
    );
  }

  // GET /api/stock-movements/stats - Statistiques globales
  Future<Map<String, dynamic>> getStockMovementStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMock) {
      return {
        'totalEntrees': _mockMovements.where((m) => m.quantity > 0).length,
        'totalSorties': _mockMovements.where((m) => m.quantity < 0).length,
        'totalMovements': _mockMovements.length,
      };
    }

    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/stock-movements/stats',
        queryParameters: params,
        options: await _getHeaders(),
      );
      
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Endpoint /api/stock-movements/stats non trouvé - retour stats MOCK');
        return {
          'totalEntrees': _mockMovements.where((m) => m.quantity > 0).length,
          'totalSorties': _mockMovements.where((m) => m.quantity < 0).length,
          'totalMovements': _mockMovements.length,
        };
      }
      print('Erreur getStockMovementStats: ${e.message}');
      rethrow;
    }
  }

  // POST /api/stock-movements - Créer un mouvement de stock
  Future<StockMovement> createStockMovement({
    required String articleId,
    required String type,
    required int quantity,
    required int oldQuantity,
    required int newQuantity,
    String? reason,
    String? userId,
  }) async {
    if (_useMock) {
      final newMovement = StockMovement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        articleName: articleId,
        type: type,
        quantity: quantity,
        oldQuantity: oldQuantity,
        newQuantity: newQuantity,
        date: DateTime.now(),
        user: userId ?? 'Mock User',
        reason: reason ?? 'Test',
      );
      _mockMovements.add(newMovement);
      return newMovement;
    }

    try {
      final response = await dio.post(
        '/stock-movements',
        data: {
          'articleId': articleId,
          'type': type,
          'quantity': quantity,
          'oldQuantity': oldQuantity,
          'newQuantity': newQuantity,
          'reason': reason,
          'userId': userId,
        },
        options: await _getHeaders(),
      );
      
      return StockMovement.fromJson(response.data);
    } on DioException catch (e) {
      print('Erreur createStockMovement: ${e.message}');
      rethrow;
    }
  }

  // GET /api/stock-movements/count-by-type - Compte des mouvements par type
  Future<Map<String, dynamic>> getCountByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMock) {
      return {
        'success': true,
        'data': [
          {
            'type': 'ENTREE',
            'count': _mockMovements.where((m) => m.quantity > 0).length,
            'total_quantite': _mockMovements.where((m) => m.quantity > 0).fold(0, (sum, m) => sum + m.quantity),
          },
          {
            'type': 'SORTIE',
            'count': _mockMovements.where((m) => m.quantity < 0).length,
            'total_quantite': _mockMovements.where((m) => m.quantity < 0).fold(0, (sum, m) => sum + m.quantity.abs()),
          },
        ],
      };
    }

    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/stock-movements/count-by-type',
        queryParameters: params,
        options: await _getHeaders(),
      );
      
      return response.data is Map ? response.data : {'success': false, 'data': []};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Endpoint /api/stock-movements/count-by-type non trouvé - retour MOCK');
        return {
          'success': true,
          'data': [
            {
              'type': 'ENTREE',
              'count': _mockMovements.where((m) => m.quantity > 0).length,
              'total_quantite': _mockMovements.where((m) => m.quantity > 0).fold(0, (sum, m) => sum + m.quantity),
            },
            {
              'type': 'SORTIE',
              'count': _mockMovements.where((m) => m.quantity < 0).length,
              'total_quantite': _mockMovements.where((m) => m.quantity < 0).fold(0, (sum, m) => sum + m.quantity.abs()),
            },
          ],
        };
      }
      print('Erreur getCountByType: ${e.message}');
      return {
        'success': false,
        'message': 'Erreur API: ${e.message}',
        'data': [],
      };
    }
  }

  // GET /api/stock-movements/count-by-type/:type - Compte pour un type spécifique
  Future<Map<String, dynamic>> getCountForType(String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMock) {
      final filtered = _mockMovements.where((m) => 
        (type.toUpperCase() == 'ENTREE' && m.quantity > 0) ||
        (type.toUpperCase() == 'SORTIE' && m.quantity < 0)
      ).toList();
      
      return {
        'success': true,
        'data': {
          'type': type.toUpperCase(),
          'count': filtered.length,
          'total_quantite': filtered.fold(0, (sum, m) => sum + m.quantity.abs()),
        },
      };
    }

    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/stock-movements/count-by-type/$type',
        queryParameters: params,
        options: await _getHeaders(),
      );
      
      return response.data is Map ? response.data : {'success': false, 'data': {}};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Endpoint /api/stock-movements/count-by-type/$type non trouvé - retour MOCK');
        final filtered = _mockMovements.where((m) => 
          (type.toUpperCase() == 'ENTREE' && m.quantity > 0) ||
          (type.toUpperCase() == 'SORTIE' && m.quantity < 0)
        ).toList();
        
        return {
          'success': true,
          'data': {
            'type': type.toUpperCase(),
            'count': filtered.length,
            'total_quantite': filtered.fold(0, (sum, m) => sum + m.quantity.abs()),
          },
        };
      }
      print('Erreur getCountForType: ${e.message}');
      rethrow;
    }
  }

  // Méthode pour désactiver le mode mock
  void disableMockMode() {
    _useMock = false;
  }
}