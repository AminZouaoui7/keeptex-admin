import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../BaseScaffold.dart';
import '../../Services/ArticleService.dart';
import '../../Core/Models/ArticleModel.dart';

class StockAlertsPage extends StatefulWidget {
  const StockAlertsPage({super.key});

  @override
  State<StockAlertsPage> createState() => _StockAlertsPageState();
}

class _StockAlertsPageState extends State<StockAlertsPage> {
  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _lowStockArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLowStockArticles();
  }

  Future<void> _fetchLowStockArticles() async {
    try {
      setState(() => _isLoading = true);
      
      // Tentative 1: Utiliser l'endpoint dédié
      try {
        final articles = await _articleService.getArticlesStockFaible();
        if (articles.isNotEmpty) {
          setState(() {
            _lowStockArticles = articles;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Erreur endpoint alerte-stock: $e');
      }
      
      // Tentative 2: Filtrer depuis tous les articles
      final allArticles = await _articleService.getArticles();
      final lowStockArticles = allArticles.where((article) => article.quantite <= article.seuil).toList();
      
      setState(() {
        _lowStockArticles = lowStockArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des alertes de stock: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lowStockArticles.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune alerte de stock",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchLowStockArticles,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _lowStockArticles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final article = _lowStockArticles[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.nom,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Catégorie : ${article.categorie}"),
                            Text("Couleur : ${article.couleur}"),
                            if (article.taille != null)
                              Text("Taille : ${article.taille}"),
                            Text("Quantité : ${article.quantite} ${article.unite}"),
                            Text("Seuil : ${article.seuil}"),
                            const SizedBox(height: 8),
                            const Text(
                              '⚠ Stock inférieur au seuil',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
