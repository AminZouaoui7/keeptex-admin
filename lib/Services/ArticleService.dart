import 'package:dio/dio.dart';
import '../Core/Models/ArticleModel.dart';
import '../Core/utils/cacheHelper.dart';

class ArticleService {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.100:5000/api')); // Adapter à ton IP

  Future<Options> _getHeaders() async {
    final token = await CacheHelper().getData(key: 'token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<List<ArticleModel>> getArticles() async {
    final res = await dio.get('/articles', options: await _getHeaders());
    final data = res.data;

    return (data as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<void> addArticle(ArticleModel article) async {
    await dio.post('/articles', data: article.toJson(), options: await _getHeaders());
  }

  Future<void> updateArticle(String id, ArticleModel article) async {
    await dio.put('/articles/$id', data: article.toJson(), options: await _getHeaders());
  }

  Future<void> deleteArticle(String id) async {
    await dio.delete('/articles/$id', options: await _getHeaders());
  }

  Future<void> ajouterStock(String id, int quantite) async {
    await dio.post('/articles/$id/ajouter-stock', data: {'quantite': quantite}, options: await _getHeaders());
  }

  Future<void> retirerStock(String id, int quantite) async {
    await dio.post('/articles/$id/retirer-stock', data: {'quantite': quantite}, options: await _getHeaders());
  }

  Future<List<ArticleModel>> getArticlesStockFaible([int seuil = 5]) async {
    final res = await dio.get('/articles/alerte-stock?seuil=$seuil', options: await _getHeaders());
    final data = res.data;

    return (data as List).map((e) => ArticleModel.fromJson(e)).toList();
  }
}
