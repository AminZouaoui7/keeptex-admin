import 'package:dio/dio.dart';
import '../Core/Models/ArticleModel.dart';
import '../Core/utils/cacheHelper.dart';

class ArticleService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.128:5000/api',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  Future<Options> _getHeaders() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  bool isLowStock(ArticleModel article) {
    return article.quantite < article.seuil;
  }

  // ✅ GET /api/articles
  Future<List<ArticleModel>> getArticles() async {
    try {
      final res = await dio.get('/articles', options: await _getHeaders());
      final raw = res.data;
      final List<dynamic> data = raw is List ? raw : (raw['data'] ?? []);
      return data.map((e) => ArticleModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print('Erreur getArticles: ${e.message}');
      rethrow;
    }
  }

  // ✅ POST /api/articles
  Future<void> addArticle(ArticleModel article) async {
    try {
      final data = article.toJson();  // déjà bien typé
      print('✅ Sending article data: $data');

      final response = await dio.post(
        '/articles',
        data: data,
        options: await _getHeaders(),
      );

      print('✅ Response: ${response.statusCode} - ${response.data}');
    } on DioException catch (e) {
      print('❌ Erreur addArticle: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  // ✅ PUT /api/articles/:id
  Future<void> updateArticle(String id, ArticleModel article) async {
    await dio.put('/articles/$id', data: article.toJson(), options: await _getHeaders());
  }

  // ✅ DELETE /api/articles/:id
  Future<void> deleteArticle(String id) async {
    await dio.delete('/articles/$id', options: await _getHeaders());
  }

  // ✅ POST /api/articles/:id/ajouter-stock
  Future<void> ajouterStock(String id, int quantite) async {
    await dio.post('/articles/$id/ajouter-stock', data: {'quantite': quantite}, options: await _getHeaders());
  }

  // ✅ POST /api/articles/:id/retirer-stock
  Future<void> retirerStock(String id, int quantite) async {
    await dio.post('/articles/$id/retirer-stock', data: {'quantite': quantite}, options: await _getHeaders());
  }

  // ✅ GET /api/articles/alerte-stock
  Future<List<ArticleModel>> getArticlesStockFaible([int seuil = 5]) async {
    final res = await dio.get('/articles/alerte-stock?seuil=$seuil', options: await _getHeaders());
    final raw = res.data;
    final List<dynamic> data = raw is List ? raw : (raw['data'] ?? []);
    return data.map((e) => ArticleModel.fromJson(e)).toList();
  }
}
